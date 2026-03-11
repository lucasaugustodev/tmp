const { Client } = require('ssh2');

const SSH_CONFIG = {
  host: '216.238.116.106',
  port: 22,
  username: 'root',
  password: 'U2m%GM{Gz%nRuL}j',
  readyTimeout: 15000,
};

function exec(conn, cmd, timeout = 120000) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error(`Timeout: ${cmd.slice(0, 80)}`)), timeout);
    conn.exec(cmd, (err, stream) => {
      if (err) { clearTimeout(timer); reject(err); return; }
      let stdout = '', stderr = '';
      stream.on('data', d => stdout += d.toString());
      stream.stderr.on('data', d => stderr += d.toString());
      stream.on('close', (code) => {
        clearTimeout(timer);
        resolve({ stdout, stderr, code });
      });
    });
  });
}

async function run() {
  const conn = new Client();

  await new Promise((resolve, reject) => {
    conn.on('ready', resolve).on('error', reject).connect(SSH_CONFIG);
  });

  console.log('Connected to VM!');

  const commands = process.argv[2] || 'all';

  if (commands === 'all' || commands === 'setup') {
    // Step 1: System setup
    console.log('\n=== Step 1: Installing system dependencies ===');

    const steps = [
      ['Update apt', 'apt-get update -qq', 60000],
      ['Install essentials', 'DEBIAN_FRONTEND=noninteractive apt-get install -y -qq git curl build-essential python3 python3-pip nginx certbot python3-certbot-nginx 2>&1 | tail -5', 120000],
      ['Install Node.js 22', 'curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt-get install -y nodejs 2>&1 | tail -5', 60000],
      ['Install pnpm', 'npm install -g pnpm 2>&1 | tail -3', 30000],
      ['Check versions', 'node --version && pnpm --version && git --version && python3 --version'],
    ];

    for (const [name, cmd, timeout] of steps) {
      console.log(`  ${name}...`);
      const r = await exec(conn, cmd, timeout || 30000);
      if (r.code !== 0) console.log(`  WARNING: ${name} exit=${r.code}: ${r.stderr.slice(0, 200)}`);
      else console.log(`  OK: ${r.stdout.trim().slice(0, 200)}`);
    }
  }

  if (commands === 'all' || commands === 'clone') {
    // Step 2: Clone and setup repo
    console.log('\n=== Step 2: Cloning hiveclip repo ===');

    // First, add our SSH key to authorized_keys
    const pubkey = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMg8z4RdhbP69jHzhoiRO5Jm3P1gtXULyDwb3hyfE+ww PC@DESKTOP-6MMFJN0';
    await exec(conn, `mkdir -p /root/.ssh && echo '${pubkey}' >> /root/.ssh/authorized_keys && chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys`);
    console.log('  SSH key added to authorized_keys');

    // Clone repo - use rsync/scp instead since it's a local project
    // For now, let's init a bare git repo and push to it
    const r = await exec(conn, 'mkdir -p /opt/hiveclip && ls /opt/hiveclip/package.json 2>/dev/null && echo "EXISTS" || echo "EMPTY"');
    console.log(`  Repo status: ${r.stdout.trim()}`);
  }

  if (commands === 'all' || commands === 'sshkey') {
    // Add SSH key
    const pubkey = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMg8z4RdhbP69jHzhoiRO5Jm3P1gtXULyDwb3hyfE+ww PC@DESKTOP-6MMFJN0';
    const r = await exec(conn, `mkdir -p /root/.ssh && grep -q '${pubkey.split(' ')[1]}' /root/.ssh/authorized_keys 2>/dev/null && echo 'ALREADY_EXISTS' || (echo '${pubkey}' >> /root/.ssh/authorized_keys && chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys && echo 'ADDED')`);
    console.log(`SSH key: ${r.stdout.trim()}`);
  }

  conn.end();
  console.log('\nDone!');
}

run().catch(e => { console.error('Error:', e.message); process.exit(1); });
