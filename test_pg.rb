require 'pg'
require 'json'

# Load internal and public URLs from the vars files
postgres_vars = JSON.parse(File.read('postgres_vars.json'))
public_url = postgres_vars['DATABASE_PUBLIC_URL']

def try_connect(url, name)
  puts "Trying #{name}..."
  begin
    conn = PG.connect(url)
    puts "✅ #{name} Success!"
    conn.close
  rescue => e
    puts "❌ #{name} Failed: #{e.message}"
  end
end

try_connect(public_url, "Public URL (default)")
try_connect(public_url + "?sslmode=disable", "Public URL (sslmode=disable)")
try_connect(public_url + "?sslmode=require", "Public URL (sslmode=require)")
