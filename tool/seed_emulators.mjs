// Fills the LOCAL Firebase emulators with demo accounts and a creator page,
// so the app can be tried without a real project. Run it while the
// emulators are up (tool/try_local.ps1 does both):
//
//     node tool/seed_emulators.mjs <project id>
//
// It only ever talks to 127.0.0.1, and writes as the emulators' "owner",
// which skips the security rules the same way the Firebase console does.
const project = process.argv[2];
if (!project) {
  console.error('Usage: node tool/seed_emulators.mjs <project id>');
  process.exit(1);
}
const authHost = process.env.FIREBASE_AUTH_EMULATOR_HOST || '127.0.0.1:9099';
const firestoreHost = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';
const AUTH = `http://${authHost}/identitytoolkit.googleapis.com/v1/projects/${project}`;
const DOCS = `http://${firestoreHost}/v1/projects/${project}/databases/(default)/documents/kahwa/AppData`;
const owner = { Authorization: 'Bearer owner', 'Content-Type': 'application/json' };

const val = v => v === null ? { nullValue: null }
  : v instanceof Date ? { timestampValue: v.toISOString() }
  : typeof v === 'boolean' ? { booleanValue: v }
  : Number.isInteger(v) ? { integerValue: String(v) }
  : Array.isArray(v) ? { arrayValue: { values: v.map(val) } }
  : typeof v === 'object' ? { mapValue: { fields: fields(v) } }
  : { stringValue: v };
const fields = d => Object.fromEntries(Object.entries(d).map(([k, v]) => [k, val(v)]));

async function call(url, body, method = 'POST') {
  const r = await fetch(url, { method, headers: owner, body: JSON.stringify(body) });
  if (!r.ok) throw new Error(`${method} ${url}: ${r.status} ${await r.text()}`);
}
const account = (localId, email, password, displayName) =>
  // Verified, as money only moves for verified emails.
  call(`${AUTH}/accounts`, { localId, email, password, displayName, emailVerified: true });
const doc = (path, data) => call(`${DOCS}/${path}`, { fields: fields(data) }, 'PATCH');

const now = new Date();
const daysAgo = d => new Date(now.getTime() - d * 864e5);
const wallet = (extra = {}) => ({
  current_lbp: 0, current_usd: 0, spent_lbp: 0, spent_usd: 0,
  received_lbp: 0, received_usd: 0, withdrawn_lbp: 0, withdrawn_usd: 0, ...extra,
});
const profile = (id, name, extra = {}) => ({
  id, name, username: null, tagline: '', about: '', category: null, emoji: null,
  color: 0xFF7B1424, cover: 1, links: [], price_lbp: null, price_usd: null,
  is_creator: false, tiers: {}, thanks: '', onboarded: true, fan_ids: [],
  created_at: daysAgo(20), ...extra,
});

try {
  await account('nour', 'nour@example.com', 'kahwa-demo-1', 'Nour Haddad');
  await account('sami', 'sami@example.com', 'kahwa-demo-2', 'Sami Khoury');
} catch (e) {
  console.error(String(e.message).includes('DUPLICATE')
    ? 'The emulators already hold these accounts: start them fresh.'
    : e.message);
  process.exit(1);
}

await doc('Profiles/nour', profile('nour', 'Nour Haddad', {
  username: 'nour',
  tagline: 'Illustrator in Beirut',
  about: 'I draw the streets of Beirut, one sketchbook at a time. Kahwas buy paper and ink.',
  category: 'art',
  emoji: '🎨',
  color: 0xFF0E7C86,
  cover: 2,
  links: [{ kind: 'instagram', url: 'instagram.com/nour.draws' }],
  price_lbp: 100000,
  price_usd: 1,
  is_creator: true,
  tiers: {
    t1: { name: 'Sketch club', kahwas: 1, perks: 'Members-only sketches every week' },
    t2: { name: 'Patron', kahwas: 5, perks: 'A signed print every three months' },
  },
  thanks: 'Thank you so much, it means a lot!',
}));
await doc('Usernames/nour', { user_id: 'nour' });
await doc('Wallets/nour', wallet());
await doc('Admins/nour', { note: 'demo admin' });
await doc('Goals/nour', {
  title: 'A new drawing tablet', description: 'To draw on the go.',
  target: 5000000, current: 0, currency: 'lbp', created_at: daysAgo(10),
});
await doc('Posts/welcome', {
  creator_id: 'nour', text: 'New sketchbook tour coming this week.',
  members_only: false, liked_by: [], created_at: daysAgo(2),
});
await doc('Posts/cedar', {
  creator_id: 'nour', text: '', members_only: true, liked_by: [], created_at: daysAgo(1),
});
await doc('PostBodies/cedar', { creator_id: 'nour', text: 'Secret sketch for members: the cedar study.' });

await doc('Profiles/sami', profile('sami', 'Sami Khoury', { emoji: '☕' }));
await doc('Wallets/sami', wallet({ current_lbp: 500000, current_usd: 5 }));

// Placeholder WHISH codes: the QR codes show, but pay nobody.
await doc('Config/top_up', {
  whish_qr_lbp: 'https://whish.money/pay/demo-lbp',
  whish_qr_usd: 'https://whish.money/pay/demo-usd',
});

console.log('Seeded: nour@example.com / kahwa-demo-1 (creator, admin), sami@example.com / kahwa-demo-2 (500,000 L.L. and $5)');
