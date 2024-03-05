local M = {}

local home = vim.fn.expand("$HOME")

M.config = {
	capture_file_path = home .. "/Documents/Notes/todos.md",
}

local function toggle_capture_popup()
	local popup_width = 80
	local popup_height = 20
	local win_width = vim.fn.winwidth(0)
	local win_height = vim.fn.winheight(0)
	local row = math.floor((win_height - popup_height) / 2)
	local col = math.floor((win_width - popup_width) / 2)

	if vim.g.capture_window and vim.api.nvim_win_is_valid(vim.g.capture_window) then
		-- Close the window if it exists
		vim.api.nvim_win_hide(0)
		vim.g.capture_window = nil
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

		local popup = vim.api.nvim_open_win(bufnr, true, {
			relative = "editor",
			width = popup_width,
			height = popup_height,
			row = row,
			col = col,
			-- style = "minimal",
			focusable = true,
		})
		vim.g.capture_window = popup
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
