# Lisa's Notes

A Claude Code plugin that automatically records each completed Claude interaction as a commit in [Jujutsu](https://github.com/martinvonz/jj) version control.

## Why "Lisa's Notes"?

Just like Lisa Simpson meticulously documents everything in her diary, this plugin keeps a detailed record of every change Claude makes to your codebase. Each time you finish working with Claude, the plugin automatically creates a Jujutsu commit using Claude's final response as the commit message—ensuring nothing gets lost or forgotten.

## How It Works

The plugin hooks into Claude's "Stop" event. When you end a Claude session:

1. The plugin reads Claude's conversation transcript (a JSON Lines file)
2. It parses each line looking for assistant messages
3. It extracts the **full text content** from the last assistant message (combining all text blocks)
4. It creates a Jujutsu commit using that complete message as the commit message
5. All operations are logged to `/tmp/lisas-notes-debug.log` for troubleshooting

This means every interaction with Claude results in a discrete, well-documented commit in your version history.

## Requirements

- [Jujutsu (jj)](https://github.com/martinvonz/jj) installed and available in PATH
- [jq](https://stedolan.github.io/jq/) for JSON parsing
- Your project must be a Jujutsu repository

## Installation

1. Clone this repository:
   ```bash
   git clone <repository-url> lisas-notes
   ```

2. Register the marketplace with Claude using the path to `.claude-plugin/marketplace.json`

3. Enable the lisas-notes plugin from the marketplace

## Usage

Once enabled, the plugin works automatically:

1. Work with Claude in a Jujutsu-managed repository
2. When you stop the Claude session (Ctrl+C or `/exit`), the plugin triggers
3. Your changes are committed with Claude's final response as the message

No manual intervention needed—just work with Claude and let Lisa keep the records.

## Project Structure

```
lisas-notes/
├── .claude-plugin/
│   └── marketplace.json      # Marketplace configuration
├── plugins/
│   └── lisas-notes/
│       ├── .claude-plugin/
│       │   └── plugin.json   # Plugin metadata (v1.0.5)
│       ├── hooks/
│       │   └── hooks.json    # Stop hook definition
│       └── scripts/
│           └── auto-commit.sh # The commit automation script
└── README.md
```

## Debugging

If commits aren't being created as expected, check the debug log:

```bash
tail -f /tmp/lisas-notes-debug.log
```

This log shows:
- When the hook starts and finishes
- The transcript path being read
- The extracted commit message
- Any errors from the `jj commit` command

## Author

Ian Bull
