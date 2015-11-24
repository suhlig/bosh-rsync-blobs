require 'helper'

class TestLocalURL < BoshRsyncBlobsTest
  def setup
    blobs_dir.mkdir
    @rsync_url = Pathname.new(Dir.mktmpdir('source_directory'))
    ENV['RSYNC_URL'] = @rsync_url.to_s
  end

  def test_sync_src_target
    source_file = @rsync_url.join('test-blob')
    source_file.write('hello')
    assert(source_file.exist?)

    assert_command

    test_blob = blobs_dir.join('test-blob')
    assert(test_blob.exist?, "Expect #{test_blob} to exist")
    assert_equal('hello', test_blob.read)
  end
end
