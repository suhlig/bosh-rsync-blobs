require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
	t.libs << 'test' << 'test/unit'
	t.pattern = 'test/unit/test_*.rb'
end

task :default => :test
