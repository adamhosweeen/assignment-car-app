// Market insights refresh.
//
// Downloads the two most recent yearly JPJ car-registration files from
// data.gov.my, aggregates them, and upserts the single `car_popularity` row the
// app reads. Runs monthly via Supabase Cron; also safe to invoke by hand.
//
// Why parquet and not the CSVs the old Dart tool used: the CSVs are ~83 MB and
// ~1.4M rows x 7 fields, which is 5-15s of CPU — an Edge Function is killed at
// 2s. The parquet files hold the same data at ~1.07 MB, and we decode only 3 of
// the 7 columns, which brings the work down to a few hundred milliseconds.
//
// Deploy: Supabase dashboard -> Edge Functions -> New function -> paste -> Deploy.
// Source: JPJ car registrations via data.gov.my, CC BY 4.0.

import { createClient } from 'jsr:@supabase/supabase-js@2';
import { asyncBufferFromUrl, parquetRead } from 'npm:hyparquet@1.30.1';
// data.gov.my writes these files with BROTLI, which hyparquet does not
// decode on its own — this package adds the codecs.
import { compressors } from 'npm:hyparquet-compressors@1.1.1';

const BASE_URL = 'https://storage.data.gov.my/transportation';
const SOURCE_URL =
  'https://data.gov.my/data-catalogue/registration_transactions_car';

const YEARS = 2;
const TOP_MAKERS = 15;
const TOP_MODELS = 20;
const PER_STATE = 5;

// Keeps two makers from colliding on a shared model name.
const SEP = '\u0001';

const MALAYSIAN_STATES = new Set([
  'Johor',
  'Kedah',
  'Kelantan',
  'Melaka',
  'Negeri Sembilan',
  'Pahang',
  'Perak',
  'Perlis',
  'Pulau Pinang',
  'Sabah',
  'Sarawak',
  'Selangor',
  'Terengganu',
  'WP Kuala Lumpur',
  'WP Labuan',
  'WP Putrajaya',
]);

// 'W.P. Kuala Lumpur' -> 'WP Kuala Lumpur'. Anything not a real state (the
// 'Rakan Niaga' dealer-portal rows, most notably) is dropped.
function normaliseState(raw: unknown): string | null {
  if (typeof raw !== 'string') return null;
  let s = raw.trim();
  if (s.length === 0) return null;
  if (s.startsWith('W.P. ')) s = `WP ${s.slice(5)}`;
  return MALAYSIAN_STATES.has(s) ? s : null;
}

function bump(counts: Map<string, number>, key: string): void {
  counts.set(key, (counts.get(key) ?? 0) + 1);
}

// Count desc, then name asc so equal counts always rank the same way.
function sorted(counts: Map<string, number>): [string, number][] {
  return [...counts.entries()].sort((a, b) =>
    b[1] !== a[1] ? b[1] - a[1] : a[0].localeCompare(b[0])
  );
}

function rank(counts: Map<string, number>, limit: number) {
  return sorted(counts).slice(0, limit).map(([name, count]) => ({ name, count }));
}

function rankModels(counts: Map<string, number>, limit: number) {
  return sorted(counts).slice(0, limit).map(([key, count]) => {
    const at = key.indexOf(SEP);
    return { maker: key.slice(0, at), name: key.slice(at + 1), count };
  });
}

interface Totals {
  total: number;
  skipped: number;
  makers: Map<string, number>;
  models: Map<string, number>;
  stateMakers: Map<string, Map<string, number>>;
  stateModels: Map<string, Map<string, number>>;
}

function emptyTotals(): Totals {
  return {
    total: 0,
    skipped: 0,
    makers: new Map(),
    models: new Map(),
    stateMakers: new Map(),
    stateModels: new Map(),
  };
}

function nested(
  outer: Map<string, Map<string, number>>,
  state: string,
): Map<string, number> {
  let inner = outer.get(state);
  if (inner === undefined) {
    inner = new Map();
    outer.set(state, inner);
  }
  return inner;
}

// Reads one yearly file into `totals`. Returns false when the file is not
// published yet, which is normal for the current year early in January.
async function readYear(year: number, totals: Totals): Promise<boolean> {
  const url = `${BASE_URL}/cars_${year}.parquet`;
  const head = await fetch(url, { method: 'HEAD' });
  if (!head.ok) return false; // a year not published yet is not an error

  // Only 3 of the 7 columns. Adding a 4th (date_reg) was measured to blow the
  // 2s CPU budget and return 546, so any date filtering has to happen upstream
  // of this function, not inside it.
  const columns = ['maker', 'model', 'state'];

  const file = await asyncBufferFromUrl({ url });
  await parquetRead({
    file,
    compressors,
    columns,
    onComplete: (rows: unknown[][]) => {
      for (const row of rows) {
        const maker = typeof row[0] === 'string' ? row[0].trim() : '';
        if (maker.length === 0) {
          totals.skipped++;
          continue;
        }
        const model = typeof row[1] === 'string' ? row[1].trim() : '';
        const modelKey = `${maker}${SEP}${model}`;

        totals.total++;
        bump(totals.makers, maker);
        bump(totals.models, modelKey);

        const state = normaliseState(row[2]);
        if (state !== null) {
          bump(nested(totals.stateMakers, state), maker);
          bump(nested(totals.stateModels, state), modelKey);
        }
      }
    },
  });
  return true;
}

Deno.serve(async () => {
  const startedAt = Date.now();
  try {
    const thisYear = new Date().getUTCFullYear();
    const years: number[] = [];
    for (let i = YEARS - 1; i >= 0; i--) years.push(thisYear - i);

    const firstYear = years[0];
    const lastYear = years[years.length - 1];
    const periodLabel = `${firstYear}–${lastYear} to date`;
    const periodStart = new Date(Date.UTC(firstYear, 0, 1)).toISOString();
    const periodEnd = new Date(Date.UTC(lastYear, 11, 1)).toISOString();

    const totals = emptyTotals();
    const read: number[] = [];
    for (const year of years) {
      if (await readYear(year, totals)) read.push(year);
    }

    if (totals.total === 0) {
      return Response.json(
        { error: 'No rows read — check the source files.', years },
        { status: 502 },
      );
    }

    const byState: Record<string, unknown> = {};
    for (const state of MALAYSIAN_STATES) {
      const makers = totals.stateMakers.get(state);
      const models = totals.stateModels.get(state);
      if (makers === undefined || makers.size === 0) continue;
      byState[state] = {
        makers: rank(makers, PER_STATE),
        models: rankModels(models ?? new Map(), PER_STATE),
      };
    }

    const generatedAt = new Date().toISOString();
    const payload = {
      period_label: periodLabel,
      period_start: periodStart,
      period_end: periodEnd,
      generated_at: generatedAt,
      source_url: SOURCE_URL,
      total_registrations: totals.total,
      top_makers: rank(totals.makers, TOP_MAKERS),
      top_models: rankModels(totals.models, TOP_MODELS),
      by_state: byState,
    };

    // The table is select-only under RLS, so writing needs the service role.
    // It stays on the server; it is never shipped to the app.
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );
    const { error } = await supabase.from('car_popularity').upsert({
      id: 'latest',
      period_label: periodLabel,
      generated_at: generatedAt,
      source_url: SOURCE_URL,
      total_registrations: totals.total,
      data: payload,
    });
    if (error) {
      return Response.json({ error: error.message }, { status: 500 });
    }

    return Response.json({
      ok: true,
      years_read: read,
      period_label: periodLabel,
      total_registrations: totals.total,
      skipped: totals.skipped,
      states: Object.keys(byState).length,
      elapsed_ms: Date.now() - startedAt,
      top_makers: payload.top_makers.slice(0, 10),
    });
  } catch (e) {
    return Response.json(
      { error: String(e), elapsed_ms: Date.now() - startedAt },
      { status: 500 },
    );
  }
});
