function goto_link()
  local req = { textDocument = { uri = vim.uri_from_bufnr(0) } }
  vim.lsp.buf_request(0, "textDocument/documentLink", req, function(err, result)
    if err then
      vim.api.nvim_err_writeln(err.message)
      return
    end
    for _, link in pairs(result) do
      if is_cursor_in_range(link.range) then
        goto_link_target(link.target)
        return
      end
    end
  end)
end

function is_cursor_in_range(range)
  local cursor = vim.api.nvim_win_get_cursor(0)
  cursor[1] = cursor[1] - 1 -- Adjust line number for 0-indexing
  cursor[2] = utf16_offset(cursor[1] + 1, cursor[2]) -- Convert the byte index to a UTF-16 character index
  -- check if cursor line is in range
  if (cursor[1] > range.start.line and cursor[1] < range['end'].line) then
    return true
  elseif cursor[1] == range.start.line and cursor[1] == range['end'].line then
    -- when cursor and range are in the same line, check the character index
    return cursor[2] >= range.start.character and cursor[2] <= range['end'].character
  elseif cursor[1] == range.start.line then
    return cursor[2] >= range.start.character
  elseif cursor[1] == range['end'].line then
    return cursor[2] <= range['end'].character
  else
    return false
  end
end

-- Count the number of UTF-16 code units between the start of the line and the byte_idx
function utf16_offset(line, byte_idx)
  local line_str = vim.api.nvim_buf_get_lines(0, line-1, line, false)[1]
  local _, utf16_count = vim.str_utfindex(line_str, byte_idx)
  return utf16_count
end

function goto_link_target(target)
  local file_location, position = target:match('(.-)#(.*)')
  local line_no, col_no = position:match('(%d+),(%d+)')
  file_location = vim.fn.fnameescape(vim.uri_to_fname(file_location))  -- convert URI to file path
  line_no = tonumber(line_no)
  col_no = tonumber(col_no)
  vim.cmd.edit(file_location)
  vim.api.nvim_win_set_cursor(0, {line_no, col_no - 1})
end

return goto_link
