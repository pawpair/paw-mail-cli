class PawMailTui < Formula
  desc "Terminal UI for the Paw Mail email client"
  homepage "https://github.com/pawpair/paw-mail-cli"
  version "0.1.0-alpha.3"
  license "MIT"

  on_macos do
    on_arm do
      # aarch64-darwin
      url "https://paw-mail-releases.pawpair.pet/v#{version}/paw-mail-tui-aarch64-darwin.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
    on_intel do
      # x86_64-darwin
      url "https://paw-mail-releases.pawpair.pet/v#{version}/paw-mail-tui-x86_64-darwin.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  on_linux do
    on_arm do
      # aarch64-linux
      url "https://paw-mail-releases.pawpair.pet/v#{version}/paw-mail-tui-aarch64-linux.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
    on_intel do
      # x86_64-linux
      url "https://paw-mail-releases.pawpair.pet/v#{version}/paw-mail-tui-x86_64-linux.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  def install
    bin.install "paw-mail-tui"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/paw-mail-tui --version")
  end
end
