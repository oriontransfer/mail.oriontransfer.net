
require 'trenni/formatters'
require 'trenni/formatters/html/definition_list_form'
require 'trenni/formatters/html/option_select'

module VMail
	class Attributes
		def initialize(*keys, &block)
			@keys = keys
			
			@struct = Struct.new(*keys, &block)
		end
		
		def new(params)
			select(params, @struct.new)
		end
		
		def select(params, into = {})
			@keys.each do |key|
				value = params[key.to_s]
				
				if value
					if value.empty?
						into[key] = nil
					else
						into[key] = value
					end
				end
			end
			
			return into
		end
		
		def assign(parameters, object)
			@keys.each do |key|
				value = parameters[key.to_s]
				
				if value
					if value.empty?
						value = nil
					end
					
					object.public_send(:"#{key}=", value)
				end
			end
		end
	end
	
	class ViewFormatter < Trenni::Formatters::Formatter
		map(Time) do |object, options|
			# Ensure we display the time in localtime, and show the year if it is different:
			if object.localtime.year != Time.now.year
				object.localtime.strftime("%B %-d, %-l:%M%P, %Y")
			else
				object.localtime.strftime("%B %-d, %-l:%M%P")
			end
		end
		
		def number(object, **options)
			ActiveSupport::NumberHelper.number_to_delimited(object, options)
		end
		
		def approximate_number(object, **options)
			ActiveSupport::NumberHelper.number_to_human(object, options)
		end
		
		def mailto(email_address)
			Trenni::Builder.fragment do |builder|
				builder.inline(:a, :href => "mailto:#{email_address}") { builder.text email_address }
			end
		end
		
		def number_of(count, noun)
			"#{count} #{noun.pluralize(count)}"
		end
		
		# http://stackoverflow.com/questions/195740/how-do-you-do-relative-time-in-rails/195894#195894
		def self.time_in_words(timestamp, direction: :past)
			a = (Time.now-timestamp).to_i
			a *= -1 if direction == :future
			case a
				when 0 then 'right now'
				when 1 then 'a second'
				when 2..59 then a.to_s+' seconds' 
				when 60..119 then 'a minute' #120 = 2 minutes
				when 120..3540 then (a/60).to_i.to_s+' minutes'
				when 3541..7100 then 'an hour' # 3600 = 1 hour
				when 7101..82800 then ((a+99)/3600).to_i.to_s+' hours' 
				when 82801..172000 then 'a day' # 86400 = 1 day
				when 172001..518400 then ((a+800)/(60*60*24)).to_i.to_s+' days'
				when 518400..1036800 then 'a week'
				else ((a+180000)/(60*60*24*7)).to_i.to_s+' weeks'
			end
		end
		
		def self.time_ago_in_words(timestamp)
			a = (Time.now-timestamp).to_i
			case a
				when 0 then 'just now'
				else "#{self.time_in_words(timestamp)} ago"
			end
		end
	end
	
	class FormFormatter < ViewFormatter
		include Trenni::Formatters::HTML::DefinitionListForm
		
		map(Time) do |object, options|
			object.httpdate
		end
		
		def select(**options, &block)
			element(Trenni::Formatters::HTML::OptionSelect, **options, &block)
		end
	end
end
