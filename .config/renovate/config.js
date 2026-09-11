/**
 * Local-First Renovate CLI Global Configuration
 * File: config.js
 * Documentation: https://docs.renovatebot.com/
 *
 * Set the environment variables:
 * RENOVATE_CONFIG_FILE = "~/.config/renovate/config.js"
 * RENOVATE_TOKEN = "$(gh auth token)"
 */
//const fs = require('fs');
//const path = require('path');

// Dynamically read your global .npmrc file from the runner machine
//const globalNpmrcPath = path.join(process.env.HOME || process.env.USERPROFILE, '.npmrc');
//const globalNpmrcContent = fs.existsSync(globalNpmrcPath)
//  ? fs.readFileSync(globalNpmrcPath, 'utf8')
//  : '';
//const globalNpmrcContent = fs.readFileSync(globalNpmrcPath, 'utf8')

module.exports = {
  platform: 'github',                      // automatically reads 'RENOVATE_TOKEN' from your local shell.
  autodiscover: false,                     // Highly recommended for local runs! Prevents scanning your whole GitHub org.
  binarySource: 'global',                  // 'global' assumes you already have uv/mise/python installed locally.
  exposeAllEnv: true,
  repositoryCache: 'enabled',
  packageCache: 'enabled',
  cacheDir: process.env.HOME + '/.cache/renovate',
  // gitAuthor: 'Local Renovate Bot <dev@company.com>',
  prHourlyLimit: 0,                        // 0 removes hourly restrictions for immediate testing
  prConcurrentLimit: 0,                    // 0 removes concurrency caps so you see all local changes
  pinDigests: true,
  automerge: true,
  automergeType: 'pr',
  branchPrefix: 'security/',
  branchNameStrict: true,
  prFooter: '',
  allowedCommands: [ 'python', '^uv', '^mise'],
  onboarding: false,
  requireConfig: "optional",               // makes the renovate.json configuration in the repository optional
  allowShellExecutorForPostUpgradeCommands: true ,
  osvVulnerabilityAlerts: true,
  extends: [
    'config:best-practices',
    'security:gomodIndirectSecurityUpdates',
    'security:minimumReleaseAgePypi',
    //'security:only-security-updates',
    'security:openssf-scorecard',
  ],
  dependencyDashboard: false,              // skip opening an issue before a PR
  configMigration: true,
  configValidationError: true,
  inheritConfigStrict: true,
  reportFormatting: true,
  reportPath: '{{cacheDir}}/renovate/repository/{{repository}}/report.json',
  reportType: 'file',
  separateMajorMinor: true,
  packageRules: [
    {
      "matchPackagePatterns": ["*"],
      "groupName": "All Dependencies",
      "groupSlug": "all-dependencies",
    },
  ],

  //npmrc: globalNpmrcContent,
  //npmrcMerge: true,
  // dryRun: 'full',                       // Uncomment this line to test without pushing branches/PRs
};
