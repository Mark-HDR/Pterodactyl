const fs = require("fs");
const path = require("path");
const moment = require("moment-timezone");
const chalk = require("chalk");

// 📂 Direktori dasar
const BASE_DIRECTORY = "/var/lib/pterodactyl/volumes";

// 🕵️‍♂️ Daftar nama file mencurigakan (keyword)
const SUSPICIOUS_FILENAMES = [
  "proxy.txt", "ua.txt", "proxy.json",
  "ddos.js", "tls.js", "ssh.js",
  "http.js", "https.js", "tcp.js",
  "mix.js", "useragent.txt", "useragents.txt",
  "http.txt", "https.txt", "socks4.txt",
  "socks5.txt", "proxies.txt",
];

// 📦 Modul-modul mencurigakan
const SUSPICIOUS_MODULES = [
  "cloudscraper", "request", "http", "https", "http2",
  "net", "tls", "cluster", "user-agents", "crypto",
  "header-generator", "gradient-string"
];

// 🎨 Warna output
const label = {
  found: chalk.bgRed.white.bold(" FOUND "),
  file: chalk.cyanBright("📄 Suspicious File"),
  module: chalk.magentaBright("📦 Suspicious Module"),
  path: chalk.greenBright("📂 Path"),
  time: chalk.yellowBright("⏰ Time"),
  safe: chalk.bgGreen.black(" CLEAN ")
};

// 📁 Ambil semua folder dalam direktori dasar
function getAllSubdirectories(basePath) {
  return fs.readdirSync(basePath)
    .map(name => path.join(basePath, name))
    .filter(source => fs.statSync(source).isDirectory());
}

// 🔍 Deteksi file mencurigakan berdasarkan nama (case-insensitive, partial match)
function detectSuspiciousFiles(folderPath) {
  const files = fs.readdirSync(folderPath);
  return files
    .filter(file => {
      const fileLower = file.toLowerCase();
      return SUSPICIOUS_FILENAMES.some(susp => fileLower.includes(susp.toLowerCase()));
    })
    .map(file => {
      const fullPath = path.join(folderPath, file);
      const lastModified = getFormattedTime(fullPath);
      return `${label.found} ${label.file}\n${label.path}: ${fullPath}\n${label.time}: ${lastModified}\n`;
    });
}

// 📦 Cek apakah package.json mengandung module mencurigakan
function detectSuspiciousModules(packageJsonPath) {
  try {
    const content = JSON.parse(fs.readFileSync(packageJsonPath));
    const dependencies = [
      ...Object.keys(content.dependencies || {}),
      ...Object.keys(content.devDependencies || {})
    ];
    return dependencies.filter(dep => SUSPICIOUS_MODULES.includes(dep));
  } catch {
    return [];
  }
}

// 🔍 Cari file .js yang menggunakan module mencurigakan
function findModuleUsage(folderPath, suspiciousModules) {
  const results = [];

  function traverse(currentPath) {
    const files = fs.readdirSync(currentPath);
    for (const file of files) {
      const fullPath = path.join(currentPath, file);
      const stat = fs.statSync(fullPath);

      if (stat.isDirectory()) {
        traverse(fullPath);
      } else if (file.toLowerCase().endsWith(".js")) {
        const content = fs.readFileSync(fullPath, "utf-8").toLowerCase();
        for (const mod of suspiciousModules) {
          const modLower = mod.toLowerCase();
          if (
            content.includes(`require("${modLower}")`) ||
            content.includes(`require('${modLower}')`) ||
            content.includes(`from "${modLower}"`) ||
            content.includes(`from '${modLower}'`)
          ) {
            const lastModified = getFormattedTime(fullPath);
            results.push(`${label.found} ${label.module} "${chalk.bold(mod)}"\n${label.path}: ${fullPath}\n${label.time}: ${lastModified}\n`);
            break;
          }
        }
      }
    }
  }

  traverse(folderPath);
  return results;
}

// 🕒 Format waktu dengan zona Asia/Jakarta
function getFormattedTime(filePath) {
  const stats = fs.statSync(filePath);
  return moment(stats.mtime).tz("Asia/Jakarta").format("YYYY-MM-DD HH:mm:ss");
}

// 🚀 Fungsi utama untuk scanning
function scanDdosScripts(baseDirectory) {
  const folders = getAllSubdirectories(baseDirectory);
  const findings = [];

  for (const folder of folders) {
    const foundFiles = detectSuspiciousFiles(folder);
    if (foundFiles.length > 0) {
      findings.push(...foundFiles);
      continue;
    }

    const packageJsonPath = path.join(folder, "package.json");
    if (fs.existsSync(packageJsonPath)) {
      const suspiciousModules = detectSuspiciousModules(packageJsonPath);
      if (suspiciousModules.length > 0) {
        const usages = findModuleUsage(folder, suspiciousModules);
        findings.push(...usages);
      }
    }
  }

  return findings;
}

// ▶ Jalankan scanner
const results = scanDdosScripts(BASE_DIRECTORY);
if (results.length > 0) {
  console.log(chalk.red.bold(`\n🚨 ${results.length} suspicious files/modules found:\n`));
  console.log(results.join("\n"));
} else {
  console.log(`\n${label.safe} ${chalk.green("Tidak ditemukan file atau module mencurigakan.")}\n`);
}
