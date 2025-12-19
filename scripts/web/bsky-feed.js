#!/usr/bin/env node

const BSKY_API = 'https://public.api.bsky.app/xrpc/app.bsky.feed.getAuthorFeed';

function parseArgs() {
  const args = process.argv.slice(2);
  const opts = {
    author: null,
    all: false,
    from: new Date(`${new Date().getFullYear()}-01-01`),
    to: new Date(),
  };

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === '--author' || arg === '-a') opts.author = args[++i];
    else if (arg === '--all') opts.all = true;
    else if (arg === '--from') opts.from = new Date(args[++i]);
    else if (arg === '--to') opts.to = new Date(args[++i]);
    else if (arg === '--help' || arg === '-h') {
      console.log(`
Usage: bsky-feed.js --author <handle> [options]

Options:
  --author, -a <handle>  Bluesky handle (e.g., lukastrumm.com)
  --all                  Download all posts recursively
  --from <date>          Start date (default: Jan 1 this year)
  --to <date>            End date (default: now)
`);
      process.exit(0);
    }
  }

  if (!opts.author) {
    console.error('Error: --author is required. Use --help for usage.');
    process.exit(1);
  }
  return opts;
}

function formatPost(item) {
  const { post, reason } = item;
  const { record } = post;
  return {
    date: record.createdAt.replace('T', ' ').replace(/\.\d+Z$/, ''),
    text: record.text || '',
    isReply: !!record.reply,
    isRepost: !!reason,
    likes: post.likeCount || 0,
    replies: post.replyCount || 0,
    reposts: post.repostCount || 0,
  };
}

function printTable(posts) {
  if (!posts.length) {
    console.log('No posts found.');
    return;
  }

  const maxLen = Math.min(80, Math.max(...posts.map(p => p.text.length)));
  const hr = (l, m, r) => l + '─'.repeat(21) + m + '─'.repeat(maxLen + 2) + m + '─────' + m + '─────' + m + '─────' + r;

  console.log('\n' + hr('┌', '┬', '┐'));
  console.log(`│ Date                │ ${'Post'.padEnd(maxLen)} │  💬 │  ♥️  │  🔁 │`);
  console.log(hr('├', '┼', '┤'));

  for (const p of posts) {
    const prefix = p.isReply ? '↩️ ' : p.isRepost ? '🔄 ' : '';
    const text = (prefix + p.text.replace(/\n/g, ' ')).slice(0, maxLen).padEnd(maxLen);
    console.log(`│ ${p.date} │ ${text} │ ${String(p.replies).padStart(2)}  │ ${String(p.likes).padStart(2)}  │ ${String(p.reposts).padStart(2)}  │`);
  }

  console.log(hr('└', '┴', '┘'));
  console.log(`\nTotal: ${posts.length} posts, ${posts.filter(p => p.isReply).length} replies, ${posts.reduce((s, p) => s + p.likes, 0)} likes\n`);
}

async function main() {
  const opts = parseArgs();
  const posts = [];
  let cursor = null;

  do {
    const url = new URL(BSKY_API);
    url.searchParams.set('actor', opts.author);
    url.searchParams.set('limit', '100');
    if (cursor) url.searchParams.set('cursor', cursor);

    const res = await fetch(url);
    if (!res.ok) throw new Error(`HTTP ${res.status}: ${await res.text()}`);

    const data = await res.json();
    posts.push(...data.feed.map(formatPost));
    cursor = data.cursor;

    const oldest = posts.at(-1);
    if (oldest && new Date(oldest.date) < opts.from) break;
  } while (opts.all && cursor);

  const filtered = posts.filter(p => {
    const d = new Date(p.date);
    return d >= opts.from && d <= opts.to;
  });

  printTable(filtered);
}

main().catch(e => {
  console.error('Error:', e.message);
  process.exit(1);
});
