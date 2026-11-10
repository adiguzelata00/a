// Daily leaderboard bridge for the web build published as a claude.ai
// artifact. Flutter (lib/services/leaderboard/leaderboard_web.dart) calls
// window.tengriLeaderboard; this file talks to the artifact's shared
// database through window.claude.use("db") / use("user").
//
// Data: one document per player, daily/<playerId> = { results: { date: {
// floor, score, won, finished } } } (last 31 days). Publish the page with
//   capabilities: { db: { rules: [
//     { path: "daily", read: "view", write: "owner" },
//     { path: "daily/{self}", read: "view", write: "interact" } ] },
//     user: { scopes: ["profile"] } }
// so everyone reads all rows, each player writes only their own, and only
// the owner can correct someone else's. Names are never stored: they are
// resolved per viewer with user.profiles().
(function () {
  var dbP = null;
  var userP = null;
  var chain = Promise.resolve(true);

  function use(name) {
    try {
      if (window.claude && typeof window.claude.use === 'function') {
        return window.claude.use(name).catch(function () { return null; });
      }
    } catch (e) { /* not inside a claude.ai viewer */ }
    return Promise.resolve(null);
  }
  function db() { return dbP || (dbP = use('db')); }
  function user() { return userP || (userP = use('user')); }
  async function myId() {
    var u = await user();
    return u ? await u.id() : null;
  }
  function num(v) {
    var n = Number(v);
    return isFinite(n) ? Math.max(0, Math.floor(n)) : 0;
  }

  window.tengriLeaderboard = {
    available: async function () {
      return !!(await db());
    },

    // Stores this player's result for `date` (JSON string). Writes are
    // chained so one document never has two writes in flight.
    submit: function (date, json) {
      chain = chain.then(async function () {
        try {
          var d = await db();
          var id = await myId();
          if (!d || !id) return false;
          var r = JSON.parse(json);
          var ref = d.doc('daily/' + id);
          var snap = await ref.get();
          var body = snap.exists ? JSON.parse(JSON.stringify(snap.data())) : {};
          var results = (body && typeof body.results === 'object' && body.results) || {};
          results[date] = {
            floor: num(r.floor),
            score: num(r.score),
            won: !!r.won,
            finished: !!r.finished,
          };
          var keys = Object.keys(results).sort();
          while (keys.length > 31) delete results[keys.shift()];
          await ref.set({ results: results });
          return true;
        } catch (e) {
          console.warn('[leaderboard] submit failed', e && e.code);
          return false;
        }
      });
      return chain;
    },

    // JSON array of { name, me, floor, score, won, finished } for `date`,
    // or null when the database can't be read here.
    top: async function (date) {
      try {
        var d = await db();
        if (!d) return null;
        var snap = await d.collection('daily').get();
        var id = await myId();
        var rows = [];
        snap.docs.forEach(function (doc) {
          var body = doc.data() || {};
          var e = body.results && body.results[date];
          if (!e || typeof e !== 'object') return;
          rows.push({
            id: doc.id,
            floor: num(e.floor),
            score: num(e.score),
            won: !!e.won,
            finished: !!e.finished,
          });
        });
        var u = await user();
        var people = u && rows.length ? await u.profiles(rows.map(function (r) { return r.id; })) : {};
        return JSON.stringify(rows.map(function (r) {
          var p = people[r.id];
          return {
            name: (p && p.name) || '',
            me: r.id === id,
            floor: r.floor,
            score: r.score,
            won: r.won,
            finished: r.finished,
          };
        }));
      } catch (e) {
        console.warn('[leaderboard] read failed', e && e.code);
        return null;
      }
    },
  };
})();
