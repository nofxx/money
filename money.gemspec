# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{money}
  s.version = "2.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Money Team"]
  s.date = %q{2009-03-22}
  s.description = %q{This library aids one in handling money and different currencies.}
  s.email = ["see@readme"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc"]
  s.files = ["History.txt", "MIT-LICENSE", "Manifest.txt", "README.rdoc", "Rakefile", "lib/money.rb", "lib/money/acts_as_money.rb", "lib/money/core_extensions.rb", "lib/money/errors.rb", "lib/money/money.rb", "lib/money/variable_exchange_bank.rb", "money.gemspec", "rails/init.rb", "script/console", "script/destroy", "script/generate", "spec/db/database.yml", "spec/db/schema.rb", "spec/money/acts_as_money_spec.rb", "spec/money/core_extensions_spec.rb", "spec/money/exchange_bank_spec.rb", "spec/money/money_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tmp/acts_as_money.sqlite3"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/nofxx/money}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{money}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{This library aids one in handling money and different currencies.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<newgem>, [">= 1.3.0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<newgem>, [">= 1.3.0"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<newgem>, [">= 1.3.0"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
