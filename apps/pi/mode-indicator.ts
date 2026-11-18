// Custom pi footer, rendered as pills.
//   Line 1:  [PERSONAL] [model] [thinking] [SMART ▰▰▰▱▱▱▱▱ 62k/100k]   (extension statuses)
//   Line 2:  ~/cwd  ⎇ branch ⇡1  ●3 ~12 ✖1 ?5  +120 −45  stash 2                                   ↑in ↓out  (cost in work mode)
//
// Mode comes from PI_CODING_AGENT_DIR (set by utils/pi-personal and utils/pi-work).
// Context zone is Matt Pocock's "dumb zone": models degrade past ~100k tokens of
// context regardless of window size. SMART -> WARNING -> DUMB.
// `/footer` toggles back to pi's built-in footer if something looks wrong.
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { execFile } from "node:child_process";
import os from "node:os";
import path from "node:path";

const WARN_AT = 80_000; // warning zone starts
const DUMB_AT = 100_000; // dumb zone starts
const BAR_CELLS = 8;

const RESET = "\x1b[0m";
// fg/bg are 256-colour codes. Pill = bold text on a coloured background, padded.
const pill = (text: string, fg: number, bg: number) => `\x1b[1;38;5;${fg};48;5;${bg}m ${text} ${RESET}`;
const dim = (text: string) => `\x1b[2m${text}${RESET}`;
const fgc = (text: string, c: number) => `\x1b[38;5;${c}m${text}${RESET}`;

const k = (n: number) => (n < 1000 ? `${n}` : `${(n / 1000).toFixed(n < 10_000 ? 1 : 0)}k`);

const THINKING_BG: Record<string, number> = {
	off: 240,
	minimal: 31,
	low: 37,
	medium: 98,
	high: 133,
	xhigh: 166,
	max: 160,
};

export default function (pi: ExtensionAPI) {
	const profile = path.basename(process.env.PI_CODING_AGENT_DIR ?? "");
	let enabled = true;

	const modePill = () =>
		profile === "work"
			? pill("WORK", 231, 160)
			: profile === "personal"
				? pill("PERSONAL", 16, 41)
				: pill("UNKNOWN PROFILE", 16, 220);

	const install = (ctx: any) => {
		ctx.ui.setFooter((tui: any, _theme: any, footerData: any) => {
			const unsub = footerData.onBranchChange(() => tui.requestRender());
			refresh = () => tui.requestRender();

			const modelPill = () => {
				const m = ctx.model;
				return pill(m ? String(m.name ?? m.id) : "no model", 231, 25);
			};

			const thinkingPill = () => {
				const level = String(pi.getThinkingLevel?.() ?? "off");
				return pill(`think: ${level}`, 231, THINKING_BG[level] ?? 240);
			};

			const zonePill = () => {
				const tokens = ctx.getContextUsage?.()?.tokens;
				// Unknown right after /compact until the next model response; context is small then.
				if (tokens == null) return pill(`SMART ${"▱".repeat(BAR_CELLS)} compacted`, 16, 41);
				const filled = Math.min(BAR_CELLS, Math.round((tokens / DUMB_AT) * BAR_CELLS));
				const bar = "▰".repeat(filled) + "▱".repeat(BAR_CELLS - filled);
				if (tokens < WARN_AT) return pill(`SMART ${bar} ${k(tokens)}/${k(DUMB_AT)}`, 16, 41);
				if (tokens < DUMB_AT) return pill(`⚠ WARNING ${bar} ${k(DUMB_AT - tokens)} left`, 16, 214);
				return pill(`✖ DUMB ${bar} +${k(tokens - DUMB_AT)} · /compact`, 231, 160);
			};

			return {
				dispose: unsub,
				invalidate() {},
				render(width: number): string[] {
					// ---- line 1: pills + other extensions' statuses ----
					const others = [...(footerData.getExtensionStatuses?.() ?? new Map()).entries()]
						.map(([, v]: any) => String(v))
						.filter(Boolean)
						.join(" ");
					let line1 = [modePill(), modelPill(), thinkingPill(), zonePill()].join(" ");
					if (others) line1 += "  " + others;

					// ---- line 2: cwd/branch left, tokens right ----
					let input = 0,
						output = 0,
						cost = 0;
					for (const e of ctx.sessionManager.getBranch()) {
						if (e.type === "message" && e.message.role === "assistant") {
							const u = (e.message as any).usage;
							if (!u) continue;
							input += u.input ?? 0;
							output += u.output ?? 0;
							cost += u.cost?.total ?? 0;
						}
					}
					const home = os.homedir();
					const cwd = process.cwd().startsWith(home) ? "~" + process.cwd().slice(home.length) : process.cwd();
					const branch = footerData.getGitBranch?.();
					let left = fgc(cwd, 110) + (branch ? "  " + fgc(`⎇ ${branch}`, 179) : "");
					if (gitInfo) {
						const g = gitInfo;
						if (g.ahead) left += " " + fgc(`⇡${g.ahead}`, 41);
						if (g.behind) left += " " + fgc(`⇣${g.behind}`, 214);
						const seg: string[] = [];
						if (g.conflicted) seg.push(`\x1b[1;38;5;196m!${g.conflicted}${RESET}`);
						if (g.staged) seg.push(fgc(`●${g.staged}`, 41));
						if (g.modified) seg.push(fgc(`~${g.modified}`, 214));
						if (g.deleted) seg.push(fgc(`✖${g.deleted}`, 203));
						if (g.untracked) seg.push(fgc(`?${g.untracked}`, 75));
						left += "  " + (seg.length ? seg.join(" ") : dim("clean"));
						if (g.add || g.del) left += "  " + fgc(`+${g.add}`, 41) + " " + fgc(`−${g.del}`, 203);
						if (g.stash) left += "  " + dim(`stash ${g.stash}`);
					}
					// Subscription (personal) cost is nominal; only show real $ in work mode.
					const right = dim(`↑${k(input)} ↓${k(output)}`) + (profile === "work" ? dim(` $${cost.toFixed(2)}`) : "");
					const pad = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(right)));
					const line2 = left + pad + right;

					return [truncateToWidth(line1, width), truncateToWidth(line2, width)];
				},
			};
		});
	};

	let refresh = () => {};

	// Git status, lazygit-style. Cached so render() stays synchronous; refreshed after
	// tool calls/turns AND on a timer, so changes made in other panes (lazygit, workers) show up.
	//   ●staged  ~modified  ✖deleted  ?untracked  !conflicted   ⇡ahead ⇣behind   +added −removed (tracked)
	type GitInfo = {
		staged: number; modified: number; deleted: number; untracked: number; conflicted: number;
		add: number; del: number; ahead: number; behind: number; stash: number;
	};
	let gitInfo: GitInfo | null = null;
	let diffBusy = false;
	const git = (args: string[]) =>
		new Promise<string>((resolve, reject) =>
			execFile("git", args, { cwd: process.cwd(), timeout: 4000, maxBuffer: 16_000_000 }, (err, out) =>
				err ? reject(err) : resolve(out),
			),
		);
	const CONFLICT = new Set(["DD", "AU", "UD", "UA", "DU", "AA", "UU"]);
	const refreshDiff = async () => {
		if (diffBusy) return;
		diffBusy = true;
		try {
			// -uall lists every untracked file instead of collapsing directories.
			const [st, num, ab, stash] = await Promise.all([
				git(["status", "--porcelain=v1", "-uall"]),
				git(["diff", "--numstat", "HEAD"]).catch(() => ""),
				git(["rev-list", "--left-right", "--count", "@{u}...HEAD"]).catch(() => ""),
				git(["stash", "list"]).catch(() => ""),
			]);
			const g: GitInfo = { staged: 0, modified: 0, deleted: 0, untracked: 0, conflicted: 0, add: 0, del: 0, ahead: 0, behind: 0, stash: 0 };
			for (const line of st.split("\n")) {
				if (line.length < 3) continue;
				const x = line[0], y = line[1], xy = line.slice(0, 2);
				if (xy === "??") { g.untracked++; continue; }
				if (CONFLICT.has(xy)) { g.conflicted++; continue; }
				if (x !== " ") g.staged++;
				if (x === "D" || y === "D") g.deleted++;
				else if (y !== " ") g.modified++;
			}
			for (const line of num.split("\n")) {
				const [a, d] = line.split("\t");
				if (!a) continue;
				g.add += Number(a) || 0; // "-" for binary files -> 0
				g.del += Number(d) || 0;
			}
			const [behind, ahead] = ab.trim().split(/\s+/).map(Number);
			g.behind = behind || 0;
			g.ahead = ahead || 0;
			g.stash = stash.split("\n").filter(Boolean).length;
			gitInfo = g;
		} catch {
			gitInfo = null; // not a git repo
		} finally {
			diffBusy = false;
			refresh();
		}
	};
	let poll: ReturnType<typeof setInterval> | undefined;

	pi.on("session_start", async (_e, ctx) => {
		if (enabled) install(ctx);
		void refreshDiff();
		if (poll) clearInterval(poll);
		poll = setInterval(() => void refreshDiff(), 4000);
		poll.unref?.();
	});
	pi.on("session_shutdown" as any, async () => {
		if (poll) clearInterval(poll);
	});
	for (const ev of ["tool_result", "turn_end", "agent_end"] as const) {
		pi.on(ev as any, async () => void refreshDiff());
	}
	for (const ev of ["turn_end", "model_select", "thinking_level_select", "session_compact", "message_end"] as const) {
		pi.on(ev as any, async () => refresh());
	}

	pi.registerCommand("footer", {
		description: "Toggle pill footer / built-in footer",
		handler: async (_args, ctx) => {
			enabled = !enabled;
			if (enabled) install(ctx);
			else ctx.ui.setFooter(undefined);
			ctx.ui.notify(enabled ? "Pill footer on" : "Built-in footer restored", "info");
		},
	});
}
