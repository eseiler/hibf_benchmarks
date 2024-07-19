from bokeh import events
from bokeh.models import AdaptiveTicker, CustomJS, CustomJSTickFormatter, FactorRange, HoverTool, Legend, LinearAxis, TabPanel, Div, Toggle, Tabs
from bokeh.layouts import column
from bokeh.plotting import save

from components.plot_css_html import create_latex_text, get_hover_code, get_button_style, get_tab_style, get_global_style

time_plot_hovers = []
size_plot_hovers = []
normal_time_description_list = []
advanced_time_description_list = []
normal_size_description_list = []
advanced_size_description_list = []

def add_hover_tool(plot, renderer, key, display_key, file_name, format_selection):
    """Fügt dem Plot ein Hover-Tool hinzu."""
    if file_name in ("none", "U", "U+R"):
        file_name = "tmax"
    if format_selection == "TIME_FORMAT":
        percentage_name = key.replace("in_seconds", "percentage")
        normal_time_description = [
            (file_name, "@SUBKEY_VALUE"),
            ("Wall clock time", "@wall_clock_time_in_seconds{0.00} sek"),
            (display_key, "@$name{0.00} sek"),
            ("Percentage", f"@{percentage_name}{{0.00}}%"),
        ]
        advanced_time_description = normal_time_description + [
            ("Compute minimizer (avg)", "@compute_minimiser_avg_in_seconds{0.00} sek"),
            ("Query IBF (avg)", "@query_ibf_avg_in_seconds{0.00} sek"),
            ("advanced", "advanced")
        ]
        normal_time_description_list.append(normal_time_description)
        advanced_time_description_list.append(advanced_time_description)
        hover_tool = HoverTool(tooltips=normal_time_description, renderers=[renderer])
        plot.add_tools(hover_tool)
        time_plot_hovers.append(hover_tool)
    else:
        percentage_name = key.replace("GB_SIZE", "GB_SIZE_percentage")
        avg_load_factor = key.replace("GB_SIZE", "AVG_LOAD_FACTOR")
        normal_size_description = [
            (file_name, "@SUBKEY_VALUE"),
            ("Total size", "@GB_TOTAL_SIZE{0.00}GB"),
            (display_key, "@$name{0.00}GB"),
            ("Percentage", f"@{percentage_name}{{0.00}}%"),
        ]
        advanced_size_description = normal_size_description + [
            ("Load Factor (avg)", f"@{avg_load_factor}{{0.00}}"),
            ("advanced", "advanced"),
        ]
        normal_size_description_list.append(normal_size_description)
        advanced_size_description_list.append(advanced_size_description)
        hover_tool = HoverTool(tooltips=normal_size_description, renderers=[renderer])
        plot.add_tools(hover_tool)
        size_plot_hovers.append(hover_tool)

def add_legend(plot, renderers, file_name, time_names, size_names, format_selection, location):
    """Fügt dem Plot eine Legende hinzu."""
    key_format = time_names if format_selection == "TIME_FORMAT" else size_names
    legend_items = []
    for i, renderer in enumerate(renderers):
        display_key = key_format[i]
        key = renderer.name
        legend_items.append((display_key, [renderer]))
        add_hover_tool(plot, renderer, key, display_key, file_name, format_selection)
    legend = Legend(items=legend_items)
    legend.location = "left"
    legend.orientation = "vertical"
    legend.glyph_height = 4
    legend.glyph_width = 12
    legend.spacing = 0
    legend.click_policy = "mute"
    plot.add_layout(legend, location)
    toggle_legend_js = CustomJS(
        args={"legend": legend},
        code="""
            legend.visible = !legend.visible
            """,
    )
    plot.js_on_event(events.DoubleTap, toggle_legend_js)

def add_second_y_axis(plot, y_range):
    """Fügt dem Plot eine zweite y-Achse hinzu."""
    plot.extra_y_ranges = {"additional_axis": FactorRange(factors=y_range)}
    second_y_axis = LinearAxis(y_range_name="additional_axis")
    second_y_axis.major_label_text_font_size = "1pt"
    second_y_axis.major_label_text_color = "#15191c"
    plot.add_layout(second_y_axis, "right")

def configure_time_plot(plot, scale_in_minutes):
    """Konfiguriert den Zeit-Plot."""
    if scale_in_minutes:
        plot.xaxis.ticker = AdaptiveTicker(base=60, min_interval=60)
        plot.xaxis.axis_label = "time in minutes"
        plot.xaxis.formatter = CustomJSTickFormatter(code="return (tick / 60);")
    else:
        plot.xaxis.ticker = AdaptiveTicker(base=10, min_interval=10)
        plot.xaxis.axis_label = "time in seconds"
    plot.toolbar_location = None
    plot.toolbar.logo = None
    plot.yaxis.visible = False
    plot.y_range.range_padding = 0.1
    plot.ygrid.grid_line_color = None
    plot.sizing_mode = "scale_both"

def configure_size_plot(plot):
    """Konfiguriert den Größen-Plot."""
    plot.toolbar.logo = None
    plot.toolbar_location = None
    plot.y_range.range_padding = 0.1
    plot.ygrid.grid_line_color = None
    plot.axis.minor_tick_line_color = None
    plot.outline_line_color = None
    plot.axis.minor_tick_line_color = None
    plot.yaxis.major_tick_line_color = None
    plot.yaxis.minor_tick_line_color = None
    plot.yaxis.major_label_standoff = 15
    plot.sizing_mode = "scale_both"

def add_description_tab(tabs):
    text_div = Div(text=create_latex_text(), styles={"color": "white", "font-size": "14px"})
    toggle_button = Toggle(label='Advanced Mode', button_type='success', stylesheets=get_button_style())
    toggle_button.js_on_click(CustomJS(args=dict(
        plot1_hovers=time_plot_hovers,
        hover1_desc1=normal_time_description_list,
        hover1_desc2=advanced_time_description_list,
        plot2_hovers=size_plot_hovers,
        hover2_desc1=normal_size_description_list,
        hover2_desc2=advanced_size_description_list),
        code=get_hover_code()))
    tabs.append(TabPanel(child=column(text_div, toggle_button), title="Description"))

def save_tabs(tabs):
    add_description_tab(tabs)
    back_tab = TabPanel(child=Div(text=""), title="⤺ Back to gallery")
    tabs.append(back_tab)
    final_tab = Tabs(tabs=tabs, sizing_mode="scale_both", stylesheets=[get_tab_style()+f".bk-tab:nth-child({len(tabs)}){{margin-left:auto;}}", get_global_style()])
    toggle_legend_js = CustomJS(
        args={"legend": final_tab, "pos": len(tabs) - 1},
        code="""
            if (legend.active === pos) {
            window.location.href = "index.html";
            }
            """,
    )
    final_tab.js_on_change("active", toggle_legend_js)
    save(final_tab)