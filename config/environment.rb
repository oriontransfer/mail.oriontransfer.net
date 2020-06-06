# frozen_string_literal: true

require 'bundler/setup'
Bundler.setup

require 'utopia/setup'
UTOPIA ||= Utopia.setup

require_relative '../db/environment'
ActiveRecord::Base.setup_connection(Variant.for(:database))

require 'vmail'
