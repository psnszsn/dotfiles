local function remove_comment_lines()
  local bufnr = vim.api.nvim_get_current_buf()
  local lang = vim.fn.fnamemodify(vim.fn.expand('%:t'), ':e')

  local parser = vim.treesitter.get_parser(bufnr, lang)
  if not parser then
    print("Tree-sitter parser not available for language: " .. lang)
    return
  end

  local tree = parser:parse()
  local root = tree[1]:root()

  local comment_nodes = {}
  local function visit_node(node)
    local node_type = node:type()

    if node_type == 'comment' then
      table.insert(comment_nodes, node)
    else
      for child in node:iter_children() do
        visit_node(child)
      end
    end
  end

  visit_node(root)

  table.sort(comment_nodes, function(a, b)
    return a:start() > b:start()
  end)

  for _, node in ipairs(comment_nodes) do
    local start_row, start_col, end_row, end_col = node:range()
    for row = start_row, end_row do
      vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, {})
    end
  end
end

vim.api.nvim_create_user_command('RemoveCommentLines', remove_comment_lines, {})
