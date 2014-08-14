# PrawnCalendar

This gem provides a class to generate calendars with schedules using prawn.

* Weekly overview
* Specifiy hours of a day to show
* Handle schedules out of the limits of a day
* Indicate recurring schedules

see [Sample output](spec/output/testcalendar.pdf)

## Installation

Add this line to your application's Gemfile:

    gem 'prawn_calendar'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install prawn_calendar

## Usage

PrawnCalendar is a ruby library. See the spec 
how to use it.

For the impatient ...

~~~~ruby
  it "implicit creates a calendar" do
    Prawn::Document.generate("calendar.pdf") do
      calendar=PrawnCalendar::WeeklyCalendar.new(self)
      calendar.mk_calendar([20,700], width:500,height:250) do
                cal_entry("2013-05-04T08:00:00+01:00", "2013-05-04T19:00:00", "cc 7as ist ein test, der laufen muss")

      end
    end
  end
~~~~

## History

* 1.0.0 2014-08-14

    Released as 1.0.0 after testing with Prawn 1.2.1


## Limitations

* It does not handle schedules over multiple days
* Only generates week calendars
* cannot colorize calendars
* no exception handling

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
