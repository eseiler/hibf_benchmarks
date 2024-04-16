# INPUTS
# peak_memory_usage_in_kibibytes	index_size_in_kibibytes	configured_threads	wall_clock_time_in_seconds	user_time_in_seconds	system_time_in_seconds	cpu_usage_in_percent	determine_query_length_in_seconds	complete_search_in_seconds	query_file_io_in_seconds	load_index_in_seconds	parallel_search_in_seconds	cpu_usage_parallel_search_in_percent	compute_minimiser_max_in_seconds	compute_minimiser_avg_in_seconds	query_ibf_max_in_seconds	query_ibf_avg_in_seconds	generate_results_max_in_seconds	generate_results_avg_in_seconds
# 1230196							884722					4					28.90						109.29					1.40					383.03					0.00								28.89						1.20						0.40					27.52						397.20									2.18								2.17								25.19						24.93						0.10							0.10

config <- yaml::read_yaml("parameters.yaml")
TIME_FORMAT <- config$TIME_FORMAT
SIZE_FORMAT <- config$SIZE_FORMAT

args <- commandArgs(trailingOnly = TRUE)
FILE_PATHS <- args[2:length(args)]

SELECTED_FORMAT <- TIME_FORMAT
file_name <- "time"
if (args[1] == "size_format") {
    SELECTED_FORMAT <- SIZE_FORMAT
    file_name <- "size"
}

extract_part <- function(file) {
    parts <- strsplit(sub("^.*/(.+)/(.+)", "\\1", file), "=")[[1]]
    key <- parts[1]
    value <- as.numeric(gsub("_", ".", parts[2], fixed = TRUE))
    subkey <- paste(key, value, sep = "=")
    return(list(key, subkey))
}

search_pattern <- function(LAYOUT_FILE, pattern) {
    file_content <- readLines(LAYOUT_FILE)
    combined_pattern <- paste(pattern, "false", sep = ".*")
    matches <- grepl(combined_pattern, file_content)
    if (any(matches)) 1 else 0
}

get_key <- function(key) {
    if (startsWith(key, "none=") || startsWith(key, "U=") || startsWith(key, "U+R=")) {
        params <- strsplit(key, "=")[[1]]
        key <- paste("tmax", params[2], sep = "=")
    }
    return(key)
}

read_and_modify <- function(FILE_PATH) {
    data <- read.delim(FILE_PATH, comment.char = "#", sep = "\t", header = TRUE)
    extracted_part <- extract_part(FILE_PATH)
    data$KEY <- extracted_part[[1]]
    data$SUBKEY <- get_key(extracted_part[[2]])
    print(data)
    data <- data[SELECTED_FORMAT]
    return(data)
}

list_of_dfs <- lapply(FILE_PATHS, read_and_modify)
combined_df <- do.call(rbind, list_of_dfs)

write.table(combined_df, file = file.path(config$BUILD_DIR, file_name), sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)
