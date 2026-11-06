//! Light/dark theme tokens from the theme broker's generated web snapshots.
//!
//! `generated/theme.{css,json}` are the `web-theme-blackbox` flake output and
//! `generated/honey/theme.{css,json}` the `web-theme-blackbox-honey` output,
//! committed so this crate builds without Nix (a flake check fails when they
//! drift). One [`Palette`] per [`Mode`] carries the figure roles and feeds HTML
//! ([`Palette::css`]), matplotlib ([`Palette::matplotlib_rc`]) and Python hosts
//! (`python::register`, feature `python`); the free [`stylesheet`] and [`role`]
//! functions are the default Blackbox snapshot, and [`BLACKBOX_HONEY`] exposes
//! the same API for the paired Blackbox light + Honey dark snapshot. Dark is
//! the default mode.
//!
//! Colours drawn *on* video frames (keypoint identities, object outlines, black
//! label boxes) are deliberately not themed here: they are relative to the frame,
//! not to the page, and must look the same in both modes.

use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::{collections::BTreeMap, fmt, str::FromStr, sync::LazyLock};

const CSS: &str = include_str!("../generated/theme.css");
const JSON: &str = include_str!("../generated/theme.json");
const HONEY_CSS: &str = include_str!("../generated/honey/theme.css");
const HONEY_JSON: &str = include_str!("../generated/honey/theme.json");

/// The complete generated stylesheet: `:root` for light, the
/// `prefers-color-scheme: dark` media query and `[data-theme=light|dark]`
/// overrides, all as `--tb-<group>-<role>` custom properties.
pub fn stylesheet() -> &'static str {
    CSS
}

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Mode {
    #[default]
    Dark,
    Light,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct UnknownMode(pub String);

impl fmt::Display for UnknownMode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "unknown colour mode {:?} (expected \"dark\" or \"light\")",
            self.0
        )
    }
}

impl std::error::Error for UnknownMode {}

impl Mode {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Dark => "dark",
            Self::Light => "light",
        }
    }

    /// The first non-empty layer wins: CLI flag, environment, configuration
    /// file, then the default (dark).
    pub fn resolve(
        flag: Option<&str>,
        env: Option<&str>,
        config: Option<&str>,
    ) -> Result<Self, UnknownMode> {
        [flag, env, config]
            .into_iter()
            .flatten()
            .map(str::trim)
            .find(|value| !value.is_empty())
            .map_or(Ok(Self::default()), str::parse)
    }
}

impl FromStr for Mode {
    type Err = UnknownMode;

    fn from_str(value: &str) -> Result<Self, Self::Err> {
        match value.trim().to_ascii_lowercase().as_str() {
            "dark" | "night" => Ok(Self::Dark),
            "light" | "day" => Ok(Self::Light),
            _ => Err(UnknownMode(value.to_string())),
        }
    }
}

impl fmt::Display for Mode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.as_str())
    }
}

/// Figure tokens (`#rrggbb`) and colormap names for one mode.
#[derive(Clone, Debug, PartialEq)]
pub struct Palette {
    pub mode: Mode,
    /// Page and figure background.
    pub background: &'static str,
    /// Cards, legends and label boxes on the background.
    pub surface: &'static str,
    pub surface_alt: &'static str,
    pub border: &'static str,
    /// Primary text and lines.
    pub ink: &'static str,
    /// Secondary text, ticks and spines.
    pub muted: &'static str,
    pub link: &'static str,
    pub accent: &'static str,
    /// Status fills (pass, fail, selected); text on them uses `on_status`.
    pub positive: &'static str,
    pub negative: &'static str,
    pub highlight: &'static str,
    pub on_status: &'static str,
    /// Data: boolean masks, unavailable samples, points, boxes, reference lines.
    pub true_mask: &'static str,
    pub false_mask: &'static str,
    pub unavailable: &'static str,
    pub point: &'static str,
    pub box_fill: &'static str,
    pub reference: &'static str,
    /// Colour cycle for categorical series.
    pub categorical: [&'static str; 10],
    pub sequential_cmap: &'static str,
    pub density_cmap: &'static str,
    /// Colormap for elapsed time, used over `time_range` of its extent so the
    /// early end stays visible against the background.
    pub time_cmap: &'static str,
    pub time_range: (f32, f32),
}

/// `roles.figure` of one mode in `theme.json`.
#[derive(Deserialize)]
struct Figure {
    background: String,
    surface: String,
    surface_alt: String,
    border: String,
    ink: String,
    muted: String,
    link: String,
    accent: String,
    positive: String,
    negative: String,
    highlight: String,
    on_status: String,
    true_mask: String,
    false_mask: String,
    unavailable: String,
    point: String,
    box_fill: String,
    reference: String,
    categorical: [String; 10],
    sequential_cmap: String,
    density_cmap: String,
    time_cmap: String,
    time_range: (f32, f32),
}

#[derive(Deserialize)]
struct ModeData {
    roles: BTreeMap<String, Value>,
}

#[derive(Deserialize)]
struct Snapshot {
    dark: ModeData,
    light: ModeData,
}

static SNAPSHOT: LazyLock<Snapshot> = LazyLock::new(|| parse_snapshot(JSON));
static HONEY_SNAPSHOT: LazyLock<Snapshot> = LazyLock::new(|| parse_snapshot(HONEY_JSON));

fn parse_snapshot(json: &str) -> Snapshot {
    serde_json::from_str(json).expect("generated theme snapshot matches the web renderer schema")
}

/// A generated web snapshot: one `--tb-*` stylesheet plus the dark and light
/// role maps. [`BLACKBOX_HONEY`] is the paired Blackbox light + Honey dark
/// output. Modes stay [`Mode::Dark`]/[`Mode::Light`]; the Honey variant is
/// carried by the theme, not by a new mode.
#[derive(Clone, Copy)]
pub struct Theme {
    pub name: &'static str,
    css: &'static str,
    snapshot: &'static LazyLock<Snapshot>,
}

impl Theme {
    /// The complete generated stylesheet, including both colour schemes.
    pub fn stylesheet(&self) -> &'static str {
        self.css
    }

    /// One role of this snapshot as `#rrggbb`, e.g.
    /// `role(Mode::Dark, "ui", "accent")`.
    pub fn role(&self, mode: Mode, group: &str, name: &str) -> Option<&'static str> {
        role_in(self.snapshot, mode, group, name)
    }
}

/// The Blackbox light + Honey dark pair (`web-theme-blackbox-honey`).
pub static BLACKBOX_HONEY: Theme = Theme {
    name: "blackbox-honey",
    css: HONEY_CSS,
    snapshot: &HONEY_SNAPSHOT,
};

/// The palette lives for the whole process, so its strings are leaked once.
/// ponytail: a one-shot leak of a few hundred bytes; switch to build.rs codegen
/// if `&'static` fields ever need to be `const`.
fn leak(value: &str) -> &'static str {
    Box::leak(value.to_string().into_boxed_str())
}

fn palette(mode: Mode, data: &ModeData) -> Palette {
    let figure: Figure = serde_json::from_value(data.roles["figure"].clone())
        .expect("generated/theme.json carries roles.figure");
    Palette {
        mode,
        background: leak(&figure.background),
        surface: leak(&figure.surface),
        surface_alt: leak(&figure.surface_alt),
        border: leak(&figure.border),
        ink: leak(&figure.ink),
        muted: leak(&figure.muted),
        link: leak(&figure.link),
        accent: leak(&figure.accent),
        positive: leak(&figure.positive),
        negative: leak(&figure.negative),
        highlight: leak(&figure.highlight),
        on_status: leak(&figure.on_status),
        true_mask: leak(&figure.true_mask),
        false_mask: leak(&figure.false_mask),
        unavailable: leak(&figure.unavailable),
        point: leak(&figure.point),
        box_fill: leak(&figure.box_fill),
        reference: leak(&figure.reference),
        categorical: figure.categorical.each_ref().map(|color| leak(color)),
        sequential_cmap: leak(&figure.sequential_cmap),
        density_cmap: leak(&figure.density_cmap),
        time_cmap: leak(&figure.time_cmap),
        time_range: figure.time_range,
    }
}

pub static DARK: LazyLock<Palette> = LazyLock::new(|| palette(Mode::Dark, &SNAPSHOT.dark));
pub static LIGHT: LazyLock<Palette> = LazyLock::new(|| palette(Mode::Light, &SNAPSHOT.light));

/// One role of the default Blackbox snapshot as `#rrggbb`, e.g.
/// `role(Mode::Dark, "ui", "foregroundMuted")`; groups are `ui`, `status`,
/// `syntax` and `figure` when the snapshot has one. Use [`Theme::role`] for
/// another snapshot.
pub fn role(mode: Mode, group: &str, name: &str) -> Option<&'static str> {
    role_in(&SNAPSHOT, mode, group, name)
}

fn role_in(
    snapshot: &'static Snapshot,
    mode: Mode,
    group: &str,
    name: &str,
) -> Option<&'static str> {
    let data = match mode {
        Mode::Dark => &snapshot.dark,
        Mode::Light => &snapshot.light,
    };
    data.roles.get(group)?.get(name)?.as_str()
}

impl Palette {
    pub fn for_mode(mode: Mode) -> &'static Palette {
        match mode {
            Mode::Dark => &DARK,
            Mode::Light => &LIGHT,
        }
    }

    /// Every single-colour token as `(name, #rrggbb)`.
    pub fn colors(&self) -> [(&'static str, &'static str); 18] {
        [
            ("background", self.background),
            ("surface", self.surface),
            ("surface_alt", self.surface_alt),
            ("border", self.border),
            ("ink", self.ink),
            ("muted", self.muted),
            ("link", self.link),
            ("accent", self.accent),
            ("positive", self.positive),
            ("negative", self.negative),
            ("highlight", self.highlight),
            ("on_status", self.on_status),
            ("true_mask", self.true_mask),
            ("false_mask", self.false_mask),
            ("unavailable", self.unavailable),
            ("point", self.point),
            ("box_fill", self.box_fill),
            ("reference", self.reference),
        ]
    }

    /// `:root` custom properties (`--surface-alt`, …) plus `color-scheme`.
    pub fn css(&self) -> String {
        let mut css = format!(":root{{color-scheme:{};", self.mode);
        for (name, value) in self.colors() {
            css.push_str(&format!("--{}:{value};", name.replace('_', "-")));
        }
        css.push('}');
        css
    }

    /// matplotlib rcParams that put every default-coloured artist on this palette.
    pub fn matplotlib_rc(&self) -> Vec<(&'static str, String)> {
        let mut rc: Vec<(&'static str, String)> = [
            ("figure.facecolor", self.background),
            ("figure.edgecolor", self.background),
            ("savefig.facecolor", self.background),
            ("savefig.edgecolor", self.background),
            ("axes.facecolor", self.background),
            ("axes.edgecolor", self.muted),
            ("axes.labelcolor", self.ink),
            ("axes.titlecolor", self.ink),
            ("text.color", self.ink),
            ("xtick.color", self.muted),
            ("ytick.color", self.muted),
            ("xtick.labelcolor", self.ink),
            ("ytick.labelcolor", self.ink),
            ("grid.color", self.border),
            ("legend.facecolor", self.surface),
            ("legend.edgecolor", self.border),
            ("legend.labelcolor", self.ink),
            ("patch.edgecolor", self.ink),
            ("hatch.color", self.ink),
            ("boxplot.boxprops.color", self.ink),
            ("boxplot.whiskerprops.color", self.ink),
            ("boxplot.capprops.color", self.ink),
            ("boxplot.flierprops.markeredgecolor", self.ink),
            ("image.cmap", self.sequential_cmap),
        ]
        .into_iter()
        .map(|(key, value)| (key, value.to_string()))
        .collect();
        let cycle: Vec<String> = self.categorical.iter().map(|c| format!("'{c}'")).collect();
        rc.push((
            "axes.prop_cycle",
            format!("cycler('color', [{}])", cycle.join(", ")),
        ));
        rc
    }
}

/// WCAG 2 contrast ratio of two `#rrggbb` colours (1.0 to 21.0).
pub fn contrast(a: &str, b: &str) -> Option<f64> {
    let (la, lb) = (luminance(a)?, luminance(b)?);
    Some((la.max(lb) + 0.05) / (la.min(lb) + 0.05))
}

fn luminance(hex: &str) -> Option<f64> {
    let hex = hex.strip_prefix('#')?;
    if hex.len() != 6 {
        return None;
    }
    let channel = |i: usize| -> Option<f64> {
        let c = f64::from(u8::from_str_radix(hex.get(i..i + 2)?, 16).ok()?) / 255.0;
        Some(if c <= 0.03928 {
            c / 12.92
        } else {
            ((c + 0.055) / 1.055).powf(2.4)
        })
    };
    Some(0.2126 * channel(0)? + 0.7152 * channel(2)? + 0.0722 * channel(4)?)
}

/// PyO3 functions for a host extension module: `theme_broker::python::register(m)?`.
#[cfg(all(feature = "python", not(test)))]
pub mod python {
    use super::{Mode, Palette};
    use pyo3::{exceptions::PyValueError, prelude::*, types::PyDict};

    fn palette(mode: &str) -> PyResult<&'static Palette> {
        mode.parse::<Mode>()
            .map(Palette::for_mode)
            .map_err(|error| PyValueError::new_err(error.to_string()))
    }

    /// Every token of a mode: colours, `categorical`, colormaps and `time_range`.
    #[pyfunction]
    fn theme_palette<'py>(py: Python<'py>, mode: &str) -> PyResult<Bound<'py, PyDict>> {
        let palette = palette(mode)?;
        let tokens = PyDict::new(py);
        tokens.set_item("mode", palette.mode.as_str())?;
        for (name, value) in palette.colors() {
            tokens.set_item(name, value)?;
        }
        tokens.set_item("categorical", palette.categorical.to_vec())?;
        tokens.set_item("sequential_cmap", palette.sequential_cmap)?;
        tokens.set_item("density_cmap", palette.density_cmap)?;
        tokens.set_item("time_cmap", palette.time_cmap)?;
        tokens.set_item("time_range", palette.time_range)?;
        Ok(tokens)
    }

    /// matplotlib rcParams for `matplotlib.rcParams.update(...)`.
    #[pyfunction]
    fn theme_rc<'py>(py: Python<'py>, mode: &str) -> PyResult<Bound<'py, PyDict>> {
        let rc = PyDict::new(py);
        for (key, value) in palette(mode)?.matplotlib_rc() {
            rc.set_item(key, value)?;
        }
        Ok(rc)
    }

    #[pyfunction]
    fn theme_css(mode: &str) -> PyResult<String> {
        Ok(palette(mode)?.css())
    }

    /// Four-layer mode resolution: flag, environment, config file, default.
    #[pyfunction]
    #[pyo3(signature = (flag=None, env=None, config=None))]
    fn theme_resolve(
        flag: Option<&str>,
        env: Option<&str>,
        config: Option<&str>,
    ) -> PyResult<&'static str> {
        Mode::resolve(flag, env, config)
            .map(Mode::as_str)
            .map_err(|error| PyValueError::new_err(error.to_string()))
    }

    pub fn register(m: &Bound<'_, PyModule>) -> PyResult<()> {
        m.add_function(wrap_pyfunction!(theme_palette, m)?)?;
        m.add_function(wrap_pyfunction!(theme_rc, m)?)?;
        m.add_function(wrap_pyfunction!(theme_css, m)?)?;
        m.add_function(wrap_pyfunction!(theme_resolve, m)?)?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn every_mode_meets_wcag_contrast() {
        for palette in [&*DARK, &*LIGHT] {
            let on_page = |token: &str| contrast(token, palette.background).unwrap();
            assert!(on_page(palette.ink) >= 7.0, "{} ink", palette.mode);
            for token in [palette.muted, palette.link] {
                assert!(on_page(token) >= 4.5, "{} {token}", palette.mode);
            }
            for token in [
                palette.true_mask,
                palette.false_mask,
                palette.point,
                palette.reference,
            ] {
                assert!(on_page(token) >= 3.0, "{} data {token}", palette.mode);
            }
            for status in [palette.positive, palette.negative, palette.highlight] {
                assert!(
                    contrast(palette.on_status, status).unwrap() >= 4.5,
                    "{} status {status}",
                    palette.mode
                );
            }
            assert!(
                contrast(palette.ink, palette.surface).unwrap() >= 7.0,
                "{} card text",
                palette.mode
            );
        }
    }

    /// WCAG AA (4.5:1) for primary and secondary text on every surface step,
    /// for the figure palette and for the UI chrome roles.
    #[test]
    fn text_meets_aa_on_every_surface() {
        for mode in [Mode::Dark, Mode::Light] {
            let figure = Palette::for_mode(mode);
            let mut pairs = vec![];
            for text in [figure.ink, figure.muted] {
                for surface in [figure.background, figure.surface, figure.surface_alt] {
                    pairs.push(("figure", text, surface));
                }
            }
            let ui = |name| role(mode, "ui", name).unwrap();
            for text in [ui("foreground"), ui("foregroundMuted")] {
                for surface in [ui("background"), ui("surface"), ui("surfaceAlt")] {
                    pairs.push(("ui", text, surface));
                }
            }
            for (group, text, surface) in pairs {
                let ratio = contrast(text, surface).unwrap();
                assert!(
                    ratio >= 4.5,
                    "{mode} {group} {text} on {surface}: {ratio:.2}"
                );
            }
        }
    }

    #[test]
    fn css_and_rc_carry_every_token() {
        for palette in [&*DARK, &*LIGHT] {
            let css = palette.css();
            assert!(css.starts_with(&format!(":root{{color-scheme:{};", palette.mode)));
            for (name, value) in palette.colors() {
                assert!(
                    css.contains(&format!("--{}:{value};", name.replace('_', "-"))),
                    "{name}"
                );
                assert!(luminance(value).is_some(), "{name} is not #rrggbb");
            }
            let rc = palette.matplotlib_rc();
            let get = |key: &str| rc.iter().find(|(k, _)| *k == key).map(|(_, v)| v.as_str());
            assert_eq!(get("figure.facecolor"), Some(palette.background));
            assert_eq!(get("text.color"), Some(palette.ink));
            assert!(
                get("axes.prop_cycle")
                    .unwrap()
                    .contains(palette.categorical[9])
            );
        }
    }

    /// The snapshot keeps bekiper's themekit figure values verbatim.
    #[test]
    fn figure_values_match_the_themekit_snapshot() {
        assert_eq!(DARK.background, "#0f1318");
        assert_eq!(DARK.categorical[0], "#4c9bff");
        assert_eq!(DARK.density_cmap, "magma");
        assert_eq!(DARK.time_range, (0.25, 1.0));
        assert_eq!(LIGHT.surface, "#f6f7f9");
        assert_eq!(LIGHT.categorical[9], "#17becf");
        assert_eq!(LIGHT.density_cmap, "hot");
        assert_eq!(LIGHT.time_range, (0.0, 0.85));
    }

    #[test]
    fn stylesheet_carries_both_schemes_and_the_chrome() {
        let css = stylesheet();
        assert!(css.starts_with(":root {\n  color-scheme: light;"));
        for needle in [
            "@media (prefers-color-scheme: dark)",
            "[data-theme=dark]",
            "[data-theme=light]",
            "--tb-ui-background: #ffffff;",
            "--tb-ui-background: #000000;",
            "--tb-figure-surface-alt: #eef1f5;",
        ] {
            assert!(css.contains(needle), "{needle}");
        }
        assert_eq!(role(Mode::Light, "ui", "background"), Some("#ffffff"));
        assert_eq!(role(Mode::Dark, "status", "nope"), None);
    }

    #[test]
    fn resolve_takes_the_first_set_layer_and_defaults_to_dark() {
        assert_eq!(Mode::resolve(None, None, None), Ok(Mode::Dark));
        assert_eq!(
            Mode::resolve(None, Some(" "), Some("light")),
            Ok(Mode::Light)
        );
        assert_eq!(
            Mode::resolve(Some("Dark"), Some("light"), Some("light")),
            Ok(Mode::Dark)
        );
        assert_eq!(
            Mode::resolve(None, Some("day"), Some("dark")),
            Ok(Mode::Light)
        );
        assert!(Mode::resolve(Some("sepia"), None, None).is_err());
        assert_eq!(Mode::Light.to_string(), "light");
        assert_eq!(contrast("#fff", "#000"), None);
    }

    fn kebab(name: &str) -> String {
        let mut out = String::new();
        for c in name.chars() {
            if c == '_' {
                out.push('-');
            } else if c.is_ascii_uppercase() {
                out.push('-');
                out.push(c.to_ascii_lowercase());
            } else {
                out.push(c);
            }
        }
        out
    }

    #[test]
    fn honey_roles_match_the_inventory() {
        let ui = [
            ("background", "#000000"),
            ("backgroundAlt", "#181714"),
            ("surface", "#24221d"),
            ("surfaceAlt", "#353128"),
            ("overlay", "#353128"),
            ("foreground", "#ebdbb2"),
            ("foregroundMuted", "#bdae93"),
            ("foregroundSubtle", "#928374"),
            ("foregroundBright", "#fff1c4"),
            ("border", "#353128"),
            ("borderSubtle", "#24221d"),
            ("accent", "#e5a72b"),
            ("accentHover", "#f3c04f"),
            ("accentActive", "#c88a22"),
            ("accentMuted", "#8f6317"),
            ("onAccent", "#000000"),
            ("focus", "#f3c04f"),
            ("link", "#f3c04f"),
            ("selectionBackground", "#353128"),
            ("selectionForeground", "#ebdbb2"),
        ];
        for (name, expected) in ui {
            assert_eq!(
                BLACKBOX_HONEY.role(Mode::Dark, "ui", name),
                Some(expected),
                "ui.{name}"
            );
        }

        let status = [
            ("error", "#fb4934"),
            ("warning", "#e5a72b"),
            ("success", "#b8bb26"),
            ("info", "#83a598"),
            ("hint", "#8ec07c"),
        ];
        for (name, expected) in status {
            assert_eq!(
                BLACKBOX_HONEY.role(Mode::Dark, "status", name),
                Some(expected),
                "status.{name}"
            );
        }

        let syntax = [
            ("comment", "#928374"),
            ("string", "#b8bb26"),
            ("number", "#d3869b"),
            ("boolean", "#d3869b"),
            ("keyword", "#fb4934"),
            ("function", "#b8bb26"),
            ("type", "#f3c04f"),
            ("variable", "#ebdbb2"),
            ("constant", "#fe8019"),
            ("operator", "#fe8019"),
            ("punctuation", "#bdae93"),
            ("tag", "#8ec07c"),
            ("attribute", "#f3c04f"),
        ];
        for (name, expected) in syntax {
            assert_eq!(
                BLACKBOX_HONEY.role(Mode::Dark, "syntax", name),
                Some(expected),
                "syntax.{name}"
            );
        }
    }

    /// The paired output reuses the existing Blackbox light snapshot verbatim;
    /// scientific figures stay on `DARK`/`LIGHT` and are not replaced by Honey.
    #[test]
    fn honey_keeps_the_default_light_snapshot_and_figure_palettes() {
        assert_eq!(SNAPSHOT.light.roles, HONEY_SNAPSHOT.light.roles);
        assert_eq!(stylesheet(), CSS);
        assert_eq!(BLACKBOX_HONEY.stylesheet(), HONEY_CSS);
        assert_eq!(BLACKBOX_HONEY.name, "blackbox-honey");
        assert_eq!(DARK.background, "#0f1318");
        assert_eq!(LIGHT.surface, "#f6f7f9");
        assert_eq!(
            BLACKBOX_HONEY.role(Mode::Dark, "figure", "background"),
            Some(DARK.background)
        );
        assert_eq!(
            BLACKBOX_HONEY.role(Mode::Light, "figure", "surface"),
            Some(LIGHT.surface)
        );
    }

    /// Every UI role in the Honey dark snapshot appears in its stylesheet, and
    /// `.role()` returns the same value. Default free functions stay unchanged.
    #[test]
    fn honey_stylesheet_and_role_lookup_agree() {
        let css = BLACKBOX_HONEY.stylesheet();
        let ui = HONEY_SNAPSHOT.dark.roles["ui"].as_object().unwrap();
        for (name, value) in ui {
            let needle = format!("--tb-ui-{}: {};", kebab(name), value.as_str().unwrap());
            assert!(css.contains(&needle), "missing {needle}");
        }
        assert_eq!(
            BLACKBOX_HONEY.role(Mode::Dark, "ui", "accent"),
            Some("#e5a72b")
        );
        assert_eq!(
            BLACKBOX_HONEY.role(Mode::Light, "ui", "background"),
            Some("#ffffff")
        );
        assert_eq!(BLACKBOX_HONEY.role(Mode::Dark, "ui", "missing"), None);
        assert_eq!(role(Mode::Dark, "ui", "accent"), Some("#83a598"));
    }

    /// Primary/secondary text on every Honey surface, plus the accent pair.
    /// `subtle` is checked only against the page background: it is a tertiary
    /// token and does not meet AA on every surface step.
    #[test]
    fn honey_text_and_accent_contrast() {
        let ui = |name| BLACKBOX_HONEY.role(Mode::Dark, "ui", name).unwrap();
        for surface in ["background", "backgroundAlt", "surface", "surfaceAlt"] {
            assert!(
                contrast(ui("foreground"), ui(surface)).unwrap() >= 7.0,
                "foreground on {surface}"
            );
            assert!(
                contrast(ui("foregroundMuted"), ui(surface)).unwrap() >= 4.5,
                "foregroundMuted on {surface}"
            );
        }
        assert!(contrast(ui("foregroundSubtle"), ui("background")).unwrap() >= 4.5);
        assert!(contrast(ui("onAccent"), ui("accent")).unwrap() >= 4.5);
        assert!(contrast(ui("accent"), ui("background")).unwrap() >= 3.0);
        for status in ["error", "warning", "success", "info", "hint"] {
            let color = BLACKBOX_HONEY.role(Mode::Dark, "status", status).unwrap();
            assert!(
                contrast(color, ui("background")).unwrap() >= 3.0,
                "status.{status}"
            );
        }
    }
}
