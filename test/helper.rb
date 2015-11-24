require 'minitest/autorun'
require 'pathname'
require 'shellwords'

class BoshRsyncBlobsTest < MiniTest::Test
  def assert_bosh_rsync_blobs(expected_status = 0, *args)
    out, err, status = capture(args)
    assert_equal(expected_status, status.exitstatus, "Expected exit status to be #{expected_status}, but it was #{status.exitstatus}. STDERR is: '#{err}'")
    [out, err]
  end

  def refute_bosh_rsync_blobs(expected_status = 1, *args)
    out, err, status = capture(args)
    assert_equal(expected_status, status.exitstatus, "Expected exit status to be #{expected_status}, but it was #{status.exitstatus}.")
    [out, err]
  end

  def capture(*args)
    Open3.capture3("#{script_under_test} #{Shellwords.join(args)}", chdir: working_directory)
  end

  def script_under_test
    Pathname.new(__dir__).join('..', 'bosh-rsync-blobs')
  end

  def working_directory
    @working_directory ||= Pathname.new(Dir.mktmpdir("working_directory-#{name}"))
  end

  def blobs_dir
    working_directory.join('.blobs')
  end

  def mock_bin_dir
    Pathname.new(__dir__).join('bin')
  end
end
