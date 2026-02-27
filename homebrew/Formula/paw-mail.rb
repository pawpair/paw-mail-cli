class PawMail < Formula
  desc "Paw Mail email client — unified CLI and TUI"
  homepage "https://github.com/pawpair/paw-mail-cli"
  version "0.1.0-alpha.5"
  license "MIT"

  on_macos do
    on_arm do
      # aarch64-darwin
      url "https://paw-mail-releases.pawpair.pet/v#{version}/paw-mail-aarch64-darwin.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
    on_intel do
      # x86_64-darwin
      url "https://paw-mail-releases.pawpair.pet/v#{version}/paw-mail-x86_64-darwin.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  on_linux do
    on_arm do
      # aarch64-linux
      url "https://paw-mail-releases.pawpair.pet/v#{version}/paw-mail-aarch64-linux.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
    on_intel do
      # x86_64-linux
      url "https://paw-mail-releases.pawpair.pet/v#{version}/paw-mail-x86_64-linux.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  def install
    bin.install "paw-mail"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/paw-mail --version")
  end
end
