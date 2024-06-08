local M = {}

local home = vim.fn.expand("$HOME")

M.config = {
	capture_file_path = home .. "/Documents/Notes/fleeting.md",
}

local function toggle_capture_popup()
	local current_buf = vim.api.nvim_get_current_buf()
	local current_buf_empty = vim.api.nvim_buf_line_count(current_buf) == 1
		and vim.api.nvim_buf_get_lines(current_buf, 0, 1, false)[1] == ""

	if vim.g.capture_buffer then
		-- Close the window if it exists
		vim.api.nvim_command(":w")
		-- vim.api.nvim_win_hide(0)
		vim.api.nvim_buf_delete(0, {})
		vim.g.capture_buffer = nil
	else
		local bufnr
		for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_get_name(buf_id) == M.config.capture_file_path then
				bufnr = buf_id
				break
			end
		end

		if not bufnr then
			bufnr = vim.api.nvim_create_buf(false, false)
			vim.api.nvim_buf_set_name(bufnr, M.config.capture_file_path)
			vim.api.nvim_buf_call(bufnr, function()
				vim.api.nvim_cmd({
					cmd = "edit",
					args = { M.config.capture_file_path },
				}, {})
			end)
		end

		if not current_buf_empty then
			vim.cmd("split")
		end
		vim.api.nvim_win_set_buf(0, bufnr)

		local current_win = vim.api.nvim_get_current_win()
		local last_line = vim.api.nvim_buf_line_count(bufnr)
		local last_char = #vim.api.nvim_buf_get_lines(bufnr, last_line - 1, last_line, false)[1]
		vim.api.nvim_win_set_cursor(current_win, { last_line, last_char })
		-- vim.api.nvim_command("startinsert!")
		vim.g.capture_buffer = bufnr
	end
end

vim.api.nvim_create_user_command("Capture", function()
	toggle_capture_popup()
end, {})

vim.keymap.set("n", "<leader>k", toggle_capture_popup, { desc = "Capture" })

M.setup = function(config)
	config = config or {}
	M.config = vim.tbl_deep_extend("force", M.config, config)

	-- tbl_deep_extend does not handle metatables
	for filetype, conf in pairs(config) do
		if conf.query then
			M.config[filetype].query = conf.query
		end
	end
end

return M
