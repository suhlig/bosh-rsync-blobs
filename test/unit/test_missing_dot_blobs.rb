require 'helper'

class TestMissingDotBlobs < BoshRsyncBlobsTest
  def setup
    ENV['RSYNC_URL'] = 'example.com:873'
    @old_path = ENV['PATH']
    ENV['PATH'] = "#{mock_bin_dir}:#{ENV['PATH']}"
  end

  def teardown
    ENV.delete('RSYNC_URL')
    ENV['PATH'] = @old_path
  end

  def test_missing_rsync_url
    ENV.delete('RSYNC_URL')
    _, err = refute_command
    assert_match(%r{RSYNC_URL is required}, err)
  end

  def test_missing_blobs_dir
    _, err = refute_command
    assert_match(%r{.blobs does not exist}, err)
  end

  def test_mocked_rsync
    blobs_dir.mkdir

    out, err = assert_command
    assert_match(%r{Downloading blobs from}, err)

    blobs_dir.rmtree
  end

  def mock_bin_dir
    Pathname.new(__dir__).join('..', 'bin')
  end

  def mock_bin_dir
    Pathname.new(__dir__).join('..', 'bin')
  end
end
