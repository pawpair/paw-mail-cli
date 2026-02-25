class MailTui < Formula
  desc "Terminal UI for the Paw Mail email client"
  homepage "https://github.com/pawpair/paw-mail-cli"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      # aarch64-darwin
      url "https://github.com/pawpair/paw-mail-cli/releases/download/v#{version}/mail-tui-aarch64-darwin.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
    on_intel do
      # x86_64-darwin
      url "https://github.com/pawpair/paw-mail-cli/releases/download/v#{version}/mail-tui-x86_64-darwin.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  on_linux do
    on_arm do
      # aarch64-linux
      url "https://github.com/pawpair/paw-mail-cli/releases/download/v#{version}/mail-tui-aarch64-linux.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
    on_intel do
      # x86_64-linux
      url "https://github.com/pawpair/paw-mail-cli/releases/download/v#{version}/mail-tui-x86_64-linux.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  def install
    bin.install "mail-tui"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mail-tui --version")
  end
end
