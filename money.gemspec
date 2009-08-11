# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = %q{money}
  s.version = "2.3.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Money Team"]
  s.date = %q{2009-06-20}
  s.description = %q{This library aids one in handling money and different currencies.}
  s.email = %q{see@readme}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "History.txt",
     "MIT-LICENSE",
     "Manifest.txt",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/money.rb",
     "lib/money/acts_as_money.rb",
     "lib/money/core_extensions.rb",
     "lib/money/errors.rb",
     "lib/money/exchange_bank.rb",
     "lib/money/money.rb",
     "money.gemspec",
     "rails/init.rb",
     "spec/db/database.yml",
     "spec/db/schema.rb",
     "spec/money/acts_as_money_spec.rb",
     "spec/money/core_extensions_spec.rb",
     "spec/money/exchange_bank_spec.rb",
     "spec/money/money_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "tmp/.gitignore"
  ]
  s.homepage = %q{http://github.com/nofxx/money}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{This library aids one in handling money and different currencies.}
  s.test_files = [
    "spec/db/schema.rb",
     "spec/money/acts_as_money_spec.rb",
     "spec/money/exchange_bank_spec.rb",
     "spec/money/money_spec.rb",
     "spec/money/core_extensions_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
