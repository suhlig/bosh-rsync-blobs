require 'helper'

class TestInvocation < BoshRsyncBlobsTest
  def setup
    ENV['RSYNC_URL'] = 'example.com:873'
    @old_path = ENV['PATH']
    ENV['PATH'] = "#{mock_bin_dir.join('all-mocked')}:#{ENV['PATH']}"
  end

  def teardown
    ENV.delete('RSYNC_URL')
    ENV['PATH'] = @old_path
  end

  def test_happy_day
    blobs_dir.mkdir

    out, err = assert_bosh_rsync_blobs
    assert_match(%r{Downloading blobs from}, err)

    blobs_dir.rmtree
  end

  def test_missing_rsync_url
    ENV.delete('RSYNC_URL')
    _, err = refute_bosh_rsync_blobs
    assert_match(%r{RSYNC_URL is required}, err)
  end

  def test_missing_blobs_dir
    _, err = refute_bosh_rsync_blobs
    assert_match(%r{.blobs does not exist}, err)
  end
end
