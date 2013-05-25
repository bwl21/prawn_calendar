require 'prawn_calendar'

OUTDIR=File.dirname(__FILE__)+"/output"

describe PrawnCalendar::WeeklyCalendar do

  it "connects to a pdf document" do
    @pdf = Prawn::Document.new
  end

  it "creates a calendar" do
    @pdf = Prawn::Document.new
    calendar = PrawnCalendar::WeeklyCalendar.new(@pdf) do |c|
      c.c_date_start="2013-04-30"
    end

    #calendar2 = PrawnCalendar::WeeklyCalendar.new(@pdf)

    calendar.mk_calendar([20,700], width:500, height:250) do
      cal_entry("2013-04-30T06:30:00", "2013-04-30T07:30:00", "oben")
      cal_entry("2013-04-30T15:30:00", "2013-04-30T18:30:00", "normal", recurring: true)
      cal_entry("2013-05-01T06:30:00", "2013-05-01T18:30:00", "oben ")
      cal_entry("2013-05-02T06:30:00", "2013-05-02T23:30:00", "oben und unten")
      cal_entry("2013-05-03T15:30:00", "2013-05-03T23:30:00", "unten")
      cal_entry("2013-05-04T23:30:00", "2013-05-04T23:59:00", "ganz unten")
      cal_entry("2013-05-05T15:30:00", "2013-05-07T22:30:00", "c2 5.5 7as ist ein test, der laufen mussss öalskd jfölaksdj fssss")
      cal_entry("2013-05-06T08:00:00", "2013-05-04T19:00:00", "c3 6.5 7as ist ein test, der laufen musdddddds")
    end

    #calendar2.c_date_start= "2013-04-30"

    calendar.mk_calendar([20,300], width:500, height:250) do
      cal_entry("2013-04-29T15:30:00", "2013-04-30T18:30:00", "c1 29.4. das ist ein test, der laufen muss")
      cal_entry("2013-04-30T15:30:00", "2013-04-30T18:30:00", "c1 30.4. das ist ein test, der laufen muss")
      cal_entry("2013-05-01T15:30:00", "2013-04-30T18:30:00", "c1 01.5. das ist ein test, der laufen muss")
      cal_entry("2013-05-02T15:30:00", "2013-04-30T18:30:00", "c1 02.5. das ist ein test, der laufen muss")
      cal_entry("2013-05-03T15:30:00", "2013-04-30T18:30:00", "c1 03.3. das ist ein test, der laufen muss")
      cal_entry("2013-05-04T15:30:00", "2013-04-30T18:30:00", "c1 04.5. das ist ein test, der laufen muss")
      cal_entry("2013-05-05T15:30:00", "2013-05-07T18:30:00", "c2 5.5 7as ist ein test, der laufen mussss öalskd jfölaksdj fssss")
      cal_entry("2013-05-06T08:00:00", "2013-05-04T19:00:00", "c3 6.5 7as ist ein test, der laufen musdddddds")
    end

    @pdf.start_new_page

    calendar2 = PrawnCalendar::WeeklyCalendar.new(@pdf) do |c|
      c.c_date_start= "2013-04-30"
      c.mk_calendar([20,700], width:500, height:250) do
        cal_entry("2013-04-30T15:30:00", "2013-05-01T18:30:00", "c7 das ist ein test, der laufen muss")
        cal_entry("2013-05-05T15:30:00", "2013-05-07T18:30:00", "c8 7as ist ein test, der laufen mussss öalskd jfölaksdj fssss")
        cal_entry("2013-05-04T08:50:00", "2013-05-04T19:00:00", "c9 7as ist ein test, der laufen musdddddds")
      end
    end

    calendar2 = PrawnCalendar::WeeklyCalendar.new(@pdf) do |c|
      c.c_date_start= "2013-04-30"
      c.mk_calendar([20,300], width:500, height:250) do
        cal_entry("2013-04-30T15:30:00", "2013-05-01T18:30:00", "ca das ist ein test, der laufen muss")
        cal_entry("2013-05-05T15:30:00", "2013-05-07T18:30:00", "cb 7as ist ein test, der laufen mussss öalskd jfölaksdj fssss")
        cal_entry("2013-05-05T18:30:00", "2013-05-07T19:30:00", "cb 7as ist ein test, der laufen mussss öalskd jfölaksdj fssss")
        cal_entry("2013-05-04T08:00:00+01:00", "2013-05-07T19:00:00", "cc 7as ist ein test, der laufen musdddddds")
      end
    end

    @pdf.render_file("#{OUTDIR}/testcalendar.pdf")

  end

  it "implicit creates a calendar" do
    Prawn::Document.generate("#{OUTDIR}/implicit.pdf") do
      calendar=PrawnCalendar::WeeklyCalendar.new(self)
      calendar.mk_calendar([20,700], width:500,height:250) do
                cal_entry("2013-05-04T08:00:00+01:00", "2013-05-07T19:00:00", "cc 7as ist ein test, der laufen musdddddds")

      end
    end
  end

  it "explicit creates a calendar" do
    Prawn::Document.generate("#{OUTDIR}/explicit.pdf") do |pdf|
      calendar=PrawnCalendar::WeeklyCalendar.new(pdf)
      calendar.mk_calendar([20,700], width:500,height:250) do
      end
    end
  end
end
