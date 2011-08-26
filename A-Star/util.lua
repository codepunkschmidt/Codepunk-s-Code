-------------------------------------------
-- Various utility functions and constants
-- Some of these are mine (Lerg), some I found on the net
-- Release date: 2011-08-25
-- Version: 1.0
-- License: MIT I guess, at least my part
-------------------------------------------
 
-------------------------------------------
-- IndexOf implementation for old Corona builds
-------------------------------------------
table.indexOf = function (t, element)
    for i = 1, #t do
        if t[i] == element then
            return i
        end
    end
end
 
-------------------------------------------
-- Shuffle a table
-------------------------------------------
table.shuffle = function (t)
  local n = #t
  while n > 2 do
    -- n is now the last pertinent index
    local k = math.random(n) -- 1 <= k <= n
    -- Quick swap
    t[n], t[k] = t[k], t[n]
    n = n - 1
  end
end
 
-------------------------------------------
-- split(string, separator)
-------------------------------------------
function split(p,d)
  local t, ll
  t={}
  ll=0
  if(#p == 1) then return {p} end
    while true do
      l=string.find(p,d,ll,true) -- find the next d in the string
      if l~=nil then -- if "not not" found then..
        table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
        ll=l+1 -- save just after where we found it for searching next time.
      else
        table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
        break -- Break at end, as it should be, according to the lua manual.
      end
    end
  return t
end
 
-------------------------------------------
-- Set a value to bounds
-------------------------------------------
function clamp(value, low, high)
    if value < low then value = low
    elseif high and value > high then value = high end
    return value
end
 
-------------------------------------------
-- Check if a value in the bounds
-------------------------------------------
function inBounds(value, low, high)
    if value >= low and value <= high then
        return true
    else
        return false
    end
end
 
-------------------------------------------
-- XML Parser
-------------------------------------------
local xml = require('xml')
local handler = require('handler')
function parse_xml(filename)
    if not isSimulator then
        filename = filename:gsub('/', '_')
    end
    local file, reason = io.open(system.pathForFile(filename), 'r')
    local data
    if file then
        data = file:read('*a')
    else
        print( 'Xml open failed: ' .. reason )
        return false
    end
    local h = handler.simpleTreeHandler()
    local x = xml.xmlParser(h)
    x:parse(data)
    return h.root
end
 
-------------------------------------------
-- Lua pretty printer
-------------------------------------------
local displayvalue=
  function (s)
    if not s or type(s)=='function' or type(s)=='userdata' then
      s=tostring(s)
    elseif type(s)~='number' then
      s=string.gsub(string.format('%q',s),'^"([^"\']*)"$',"'%1'")
    end
    return s
  end
 
local askeystr=
  function (u,s)
    if type(u)=='string' and string.find(u,'^[%w_]+$') then return s..u end
    return '['..displayvalue(u)..']'
  end
 
local horizvec=
  function (x,n)
    local o,e='',''
    for i=1,table.getn(x) do
      if type(x[i])=='table' then return end
      o=o..e..displayvalue(x[i])
      if string.len(o)>n then return end
      e=','
    end
    return '('..o..')'
  end
 
local horizmap=
  function (x,n)
    local o,e='',''
    for k,v in pairs(x) do
      if type(v)=='table' then return end
      o=o..e..askeystr(k,'')..'='..displayvalue(v)
      if string.len(o)>n then return end
      e=','
    end
    return '{'..o..'}'
  end
-- This is the actual function to use
-- pprint('My table', myTable)
function pprint(p,x,h,q)
  if not p then p,x='globals',globals() end
  if type(x)=='table' then
    if not h then h={} end
    if h[x] then
      x=h[x]
    else
      if not q then q=p end
      h[x]=q
      local s={}
      for k,v in pairs(x) do table.insert(s,k) end
      if table.getn(s)>0 then
        local n=75-string.len(p)
        local f=table.getn(s)==table.getn(x) and horizvec(x,n)
        if not f then f=horizmap(x,n) end
        if not f then
          table.sort(s,function (a,b)
                   --if tag(a)~=tag(b) then a,b=tag(b),tag(a) end
                   if type(a)~=type(b) then a,b=type(b),type(a) end
                   return a<b
                 end)
          for i=1,table.getn(s) do
            if s[i] then
              local u=askeystr(s[i],'.')
              pprint(p..u,x[s[i]],h,q..u)
              p=string.rep(' ',string.len(p))
            end
          end
          return
        end
        x=f
      else
        x='{}'
      end
    end
  else
    x=displayvalue(x)
  end
  print(p..' = '..x)
end
 
-------------------------------------------
-- Print two dimensional arrays
-------------------------------------------
function print2d(t)
    for r = 0, table_len(t) - 1 do
        local str = ''
        for c = 0, table_len(t[r]) - 1 do
            local val = t[c][r] or 0 -- Codepunk: Changed to print in [x][y] direction
            val = round(val)
            if val == 0 then
                val = ' '
            end
            str = str .. val .. ' '
        end
        print(str)
    end
end
 
-------------------------------------------
-- Number rounding
-------------------------------------------
function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end
 
-------------------------------------------
-- Produce comma separated large values
-------------------------------------------
function commaThousands(amount)
    amount = tonumber(amount)
 
    local formatted = amount
        while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
            break
        end
    end
 
    return formatted
end
 
-------------------------------------------
-- Save specified value to specified file
-------------------------------------------
function saveValue(strFilename, strValue)
    local theFile = strFilename
    local theValue = strValue
    local path = system.pathForFile( theFile, system.DocumentsDirectory )
    -- io.open opens a file at path. returns nil if no file found
    local file = io.open( path, "w+" )
    if file then
       -- write game score to the text file
       file:write( theValue )
       io.close( file )
    end
end
 
-------------------------------------------
-- Load specified file, or create new file if it doesn't exist
-------------------------------------------
function loadValue(strFilename)
    local theFile = strFilename
    local path = system.pathForFile( theFile, system.DocumentsDirectory )
    -- io.open opens a file at path. returns nil if no file found
    local file = io.open( path, "r" )
    if file then
       -- read all contents of file into a string
       local contents = file:read( "*a" )
       io.close( file )
       return contents
    else
       -- create file b/c it doesn't exist yet
       file = io.open( path, "w" )
       file:write( "0" )
       io.close( file )
       return "0"
    end
end
 
-------------------------------------------
-- Check if the value is in array or sequence of arguments
-- USAGE: checkIn(value, table) OR
--        checkIn(value, arg1, arg2, arg3 ... )
-------------------------------------------
function checkIn(value, ...)
    if type(arg[1]) == 'table' then
        for k, v in pairs(arg[1]) do
            if v == value then
                return true
            end
        end
    else
        for i, v in ipairs(arg) do
            if v == value  then
                return true
            end
        end
    end
    return false
end
 
-------------------------------------------
-- Implementation of min binary heap for use as a priority queue
-- each element should have 'priority' field or one that you defined
-- when created a heap.
-------------------------------------------
function newHeap (priority)
    if not priority then
        priority = 'priority'
    end
    heapObject = {}
    heapObject.heap = {}
    heapObject.len = 0 -- Size of the heap
    function heapObject:push (newElement) -- Adds new element to the heap
        local index = self.len
        self.heap[index] = newElement -- Add to bottom of the heap
        self.len = self.len + 1 -- Increase heap elements counter
        self:heapifyUp(index) -- Maintane min heap
    end
 
    function heapObject:heapifyUp (index)
        local parentIndex = clamp(math.floor((index - 1) / 2), 0)
        if self.heap[index][priority] < self.heap[parentIndex][priority] then
            self.heap[index], self.heap[parentIndex] = self.heap[parentIndex], self.heap[index] -- Swap
            self:heapifyUp(parentIndex) -- Continue sorting up the heap
        end
    end
 
    function heapObject:pop (index) -- Returns the element with the smallest priority or specific one
        if not index then index = 0 end
        local minElement = self.heap[index]
        self.heap[index] = self.heap[self.len - 1] -- Swap
        -- Remove element from heap
        self.heap[self.len - 1] = nil
        self.len = self.len - 1
        self:heapifyDown(index) -- Maintane min heap
        return minElement
    end
 
    function heapObject:heapifyDown (index)
        local leftChildIndex = 2 * index + 1
        local rightChildIndex = 2 * index + 2
        if  (self.heap[leftChildIndex] and self.heap[leftChildIndex][priority] and self.heap[leftChildIndex][priority] < self.heap[index][priority])
            or
            (self.heap[rightChildIndex] and self.heap[rightChildIndex][priority] and self.heap[rightChildIndex][priority] < self.heap[index][priority]) then
                if (not self.heap[rightChildIndex] or not self.heap[rightChildIndex][priority]) or self.heap[leftChildIndex][priority] < self.heap[rightChildIndex][priority] then
                    self.heap[index], self.heap[leftChildIndex] = self.heap[leftChildIndex], self.heap[index] -- Swap
                    self:heapifyDown(leftChildIndex) -- Continue sorting down the heap
                else
                    self.heap[index], self.heap[rightChildIndex] = self.heap[rightChildIndex], self.heap[index] -- Swap
                    self:heapifyDown(rightChildIndex) -- Continue sorting down the heap
                end
        end
    end
 
    function heapObject:root () -- Returns the root element without removing it
        return self.heap[0]
    end
 
    return heapObject
end
 
-------------------------------------------
-- Calculate number of elements in a table
-- Correctly manages zero indexed tables
-------------------------------------------
function table_len (t)
    local len = #t + 1
    if len == 1 and t[0] == nil then
        len = 0
    end
    return len
end
 
-------------------------------------------
-- Reverse a table
-------------------------------------------
function table_reverse (t)
    local r = {}
    local tl = table_len(t)
    for k,v in pairs(t) do
        r[tl - k - 1] = v
    end
    return r
end