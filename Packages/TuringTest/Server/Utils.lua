function get_keys(l)
    local keys = {}
    for k,v in pairs(l) do
        table.insert(keys, k)
    end
    return keys
end

function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

function get_values(l)
    local values = {}
    for k,v in pairs(l) do
        table.insert(values, v)
    end
    return values
end

function remove_one_element(list, key)
    found = false
    local n_list = {}
    for i=1,#list do
        if list[i] == key and found == false then
            found = true
        else
            table.insert(n_list, list[i])
        end
    end
    return n_list
end

function table_invert(t)
	local u = { }
	for k, v in pairs(t) do u[v] = k end
	return u
end
