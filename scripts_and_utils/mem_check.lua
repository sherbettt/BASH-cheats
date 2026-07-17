#!/usr/bin/lua

-- Скрипт для проверки состояния системы

print("=== Memory Check ===")
print("Time: " .. os.date())
print("Uptime: " .. os.date("%H:%M:%S"))
print("==============")

local function get_meminfo()
    local m = io.open("/proc/meminfo", "r")
    if m then
        -- Читаем ВЕСЬ файл в одну строку
        local content = m:read("*all")  -- "*all" или "a"
        m:close()
        
        -- Ищем с правильным паттерном (%s+ - пробелы/табуляция)
        local mem_total = content:match("MemTotal:%s+(%d+)")
        local mem_free = content:match("MemFree:%s+(%d+)")
        local mem_available = content:match("MemAvailable:%s+(%d+)")
        
        -- Выводим результаты
        print(string.format("MemTotal: %s kB", mem_total or "NOT FOUND"))
        print(string.format("MemFree: %s kB", mem_free or "NOT FOUND"))
        print(string.format("MemAvailable: %s kB", mem_available or "NOT FOUND"))
        
        return mem_total, mem_free, mem_available
    end
    return nil, nil, nil
end

get_meminfo()

