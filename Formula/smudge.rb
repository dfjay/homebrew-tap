# url and sha256 are updated by the publish workflow of dfjay/smudge.
class Smudge < Formula
  desc "Multi-touch support for external USB touchscreens on macOS"
  homepage "https://github.com/dfjay/smudge"
  url "https://github.com/dfjay/smudge/releases/download/v0.1.0/smudge-0.1.0-macos-universal.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"

  depends_on macos: :sonoma

  def install
    bin.install "smudge"
  end

  # macOS grants permissions to a bare binary by path, and the Cellar path changes
  # with every version, so the service runs a copy at a stable one. Removed first:
  # overwriting a running signed binary gets it killed.
  post_install_steps do
    remove "smudge/smudge", base: :var
    copy "bin/smudge", "smudge/smudge", source_base: :prefix, target_base: :var
  end

  service do
    run [var/"smudge/smudge"]
    keep_alive true
    process_type :interactive
    error_log_path var/"log/smudge.log"
  end

  def caveats
    <<~EOS
      smudge needs Input Monitoring and Accessibility. Start it with
        brew services start smudge
      and grant both to #{var}/smudge/smudge in System Settings → Privacy & Security.

      After an upgrade, load the new version with
        brew services restart smudge
    EOS
  end

  test do
    assert_match "usage: smudge", shell_output("#{bin}/smudge --help")
  end
end
