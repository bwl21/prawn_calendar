require "prawn_calendar/version"
require 'prawn'
require 'time'
require 'date'


# this module holds all the stuff for PrawnCalendar
module PrawnCalendar

  #
  # This Class represents a weekly calendar
  #
  class WeeklyCalendar
    # the Prawn instance xxx
    attr_accessor :pdf

    # the start of the interval
    attr_accessor :c_date_start

    # the gutter of calendar annotations
    attr_accessor :c_annotation_gutter

    # the number of divisions in calender columns
    # this is to adjust the proportion of the first and
    # the subsequent columns
    # 
    # for example c_col_division = 5 and c_first_col_division = 2
    # makes the first column width be 2/5 of the calender column width
    attr_accessor :c_col_division

    # the end of the interval
    attr_accessor :c_date_end

    # An array with labels of the day. e.g. ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
    attr_accessor :c_days

    # The fontsize of calendar entries
    attr_accessor :c_entry_fontsize

    # The gutter of calendar entries
    attr_accessor :c_entry_gutter

    # The radius of the calendar entries
    attr_accessor :c_entry_radius

    # The right margin of calendar entries
    attr_accessor :c_entry_right_gutter

    # The number of Rows shown in the calendar without time
    # These rows are intended for additional comments
    attr_accessor :c_extra_rows

    # the number of divisions in the first column
    # the one showing the time
    # 
    # see [c_col_division] for more details.
    attr_accessor :c_firstcol_division

    # The font size of the calendar annotations
    attr_accessor :c_fontsize

    # the number of divisions of the calenar rows.
    # this finally determines the resolution of
    # time shown in the calendar.
    # Defaults to 4 which is (15 minutes)
    #
    attr_accessor :c_row_division

    # the time where calendar display ends (defaults to 22)
    attr_accessor :c_time_end

    # the time where calendar display starts (defaults to 8)
    attr_accessor :c_time_start


    #
    # This is the write accessor to the attributre c_cate_start.
    # Note that this adjusts the start date such that it
    # comes to a monday and sets the end of the interval
    # to the subseqent sunday
    #
    # @param  day [String] Iso 8601 form of the start date.
    #
    # @return [type] [description]
    def c_date_start=(day)
      # round to the beginning of the day.
      d = Date.iso8601(day)
      # note that we start the week on monday, therefore d -(d-1).wday
      # note that Date adds days, while Time adds seconds
      #
      # compute the beginning of the week
      @c_date_start = (d -(d-1).wday).to_time
      # set end to the last second of end date
      @c_date_end   = (@c_date_start.to_date + 7).to_time-1
    end

    #
    # This is the constructor
    # @param  pdf [Prawn] The handle to prawn which renders the calendar
    # @param  &block [Proc] Code to change the initial configruation of the calendar.
    #
    # @return [type] [description]
    def initialize(pdf, &block)
      @pdf=pdf

      @c_annotation_gutter  = 2
      @c_col_division       = 5
      self.c_date_start=(Date.today.iso8601) # default to today.
      @c_days               = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
      @c_entry_fontsize     = 7
      @c_entry_gutter       = 0
      @c_entry_radius       = 2
      @c_entry_right_gutter = 2
      @c_extra_rows         = 1
      @c_firstcol_division  = 2
      @c_fontsize           = 8
      @c_row_division       = 4
      @c_time_end           = 22
      @c_time_start         = 8
      yield(self) if block_given?
    end


    #
    # This generates an entry in the calendar gird.
    # Basically it is used for annotations.
    #
    # Note that the coordinates are counter intuitive related
    # to the usual positioning in pdf/prawn. While bounding_box
    # is [horizontal, vertical] this stuff is [vertial, horizontal]
    #
    # @param  ll [Array] left point [row, column] in grid coordinates
    #         [0,0] is the upper left corner
    #         [0,1] is the second field in the first row.
    # @param  rr [Array] end point [row, column] in grid coordinates
    #
    # @param  text [String] The string to be placed. It allows to use
    # html formatting as far as supported by prawn.
    #
    # @return nil
    def mk_entry(ll, rr, text)
      @pdf.grid(ll, rr).bounding_box do

        @pdf.stroke_bounds
        excess_text = @pdf.text_box text,
          :at            => [@c_annotation_gutter, @pdf.bounds.height - @c_annotation_gutter],
          :width         => @pdf.bounds.width  - (2 * @c_annotation_gutter),
          :height        => @pdf.bounds.height - (2 * @c_annotation_gutter),
          :overflow      => :truncate,
          :kerning       => true,
          :inline_format => true,
          :size          => @c_fontsize
      end
      nil
    end


    #
    # This makes a calendar entry based on time.
    #
    # Please note
    #
    # * it is not very robust yet
    # * it only supports single day entries
    # * entries are truncated if they do not fit into the range of hours
    #   in this case, the end time is added to the text
    #
    # @param  starttime [String] Starttime in iso8601 format
    # @param  endtime [String] Endtime in iso8601 format
    # @param  text [String] The text of calender entry
    # @param  extraargs [Hash] additional arguments
    #         :recurring true/false
    #
    # @return nil
    #
    def cal_entry(starttime, endtime, text, extraargs={})
      time_to_start = Time.iso8601(starttime).localtime
      time_to_end = Time.iso8601(endtime).localtime

      a= ((@c_date_start.to_time .. @c_date_end.to_time).cover?(time_to_start))
      puts "datum ausserhalb des Kalenders #{@c_date_start} < #{time_to_start} < #{@c_date_end} #{text}" if a==false

      hour_to_start = time_to_start.hour
      hour_to_end   = time_to_end.hour
      min_to_start  = time_to_start.min / (60/@c_row_division)
      min_to_end    = time_to_end.min / (60/@c_row_division)

      finaltext="<b>#{text}</b>"

      # handle the case that the entry is out of bounds
      # in this case it is drawn in the extra lines
      # an start/endtime is shown as extra tet
      extratext=nil



      # entry starts too early
      if (hour_to_start == 0) || (hour_to_start) < @c_time_start then
        extratext = true
        hour_to_start = @c_time_start-1
        min_to_start = 0
      end

      # entry ends too early
      if (hour_to_end == 0) || (hour_to_end) < @c_time_start then
        extratext=true
        hour_to_end= @c_time_start
        min_to_end = 0
      end

      # entry starts too late

      if (hour_to_start == 0) || (hour_to_start >= @c_time_end+1) then
        extratext = true
        hour_to_start = @c_time_end + 1
        min_to_start = 0
      end

      # entry ends too late
      if (hour_to_end == 0) || (hour_to_end >= @c_time_end+1) then
        extratext = true
        hour_to_end = @c_time_end + 2
        min_to_end = 0
      end

      if extratext then
        finaltext = finaltext + "<br><font size='#{@c_fontsize-2}'>#{time_to_start.strftime('%k.%M')} - #{time_to_end.strftime('%k.%M')}</font>"
      end




      starttime_s   = time_to_start.strftime("%k.%M")
      endtime_s     = time_to_end.strftime("%k.%M")

      text_to_show  = "#{starttime_s} - #{endtime_s}<br/>#{text}"
      text_to_show  = "#{finaltext}"

      day    = (time_to_start.wday + 6) % 7  # since we start on monday shift it one left
      column = @c_firstcol_division + day * @c_col_division

      srow = 2 * @c_row_division + (hour_to_start - @c_time_start) * @c_row_division + min_to_start
      erow = 2 * @c_row_division + (hour_to_end - @c_time_start) * @c_row_division -1 + min_to_end

      cal_entry_raw([srow, column], erow - srow, text_to_show, extraargs[:recurring])
    end


    #
    # This creates a raw calendar entry based on grid coordinates
    #
    # @param  ll [Array] Left corner, see mk_entry for details.
    # @param  length [Integer] The number of grid rows covered by the entry
    # @param  text [String] The text of the calendar entry
    #
    # @return nil
    def cal_entry_raw(ll, length, text, recurring=false)
      width=4
      ur=[ll[0]+length, ll[1]+width]
      @pdf.grid(ll,ur).bounding_box do

        @pdf.fill_color "f0f0f0"

        @pdf.line_width 0.1


        # add one pixel to the borders to keep the entry away from the lines
        @pdf.rounded_rectangle([@c_entry_gutter+1, @pdf.bounds.height - @c_entry_gutter], # startpoint
                               @pdf.bounds.width  - 2 * @c_entry_gutter - @c_entry_right_gutter -2, # width
                               @pdf.bounds.height - 2 * @c_entry_gutter, # height
                               @c_entry_radius                 # radius
                               )
        @pdf.fill_and_stroke

        @pdf.fill_color "000000"

        if recurring==true then
          @pdf.text_box "(w)",
            :at    => [@pdf.bounds.width - 13,8],
            :width => 10,
            :size => 6
        end

        if recurring==true then
          @pdf.rounded_rectangle([@pdf.bounds.width  - 2, @c_entry_gutter], # startpoint
                                 2 , # width
                                 2 , # height
                                 @c_entry_radius                 # radius
                                 )
          @pdf.fill_and_stroke
        end



        # text is limited to gutter. Therefore gutter needs to be doubled
        # no limit at right and bottom
        excess_text = @pdf.text_box text,
          :at => [@c_entry_gutter +2, @pdf.bounds.height- 2*@c_entry_gutter-1], # need 1 pixel more a the top
          :width    => @pdf.bounds.width-4*@c_entry_gutter -2*@c_entry_right_gutter,
          :height   => @pdf.bounds.height-4*@c_entry_gutter,
          :overflow => :truncate,
          :kerning  => true,
          :inline_format => true,
          :size     => @c_entry_fontsize
      end
      nil
    end



    #
    # Creates an empty calendar
    #
    # @param  ll [Array] the start point of the calendar
    #                    values are points, 0,0 is the lower left corner of the calender
    #                    see Prawn::Document.bounding_box for details
    # @param  opts [Hash] [the options, keys: :width, :height]
    # @param  &block [Proc] The statements to fill the calendar.
    #
    # @return [type] [description]
    def mk_calendar(ll, opts, &block)
      @pdf.bounding_box(ll, width: opts[:width], height: opts[:height]) do
        @pdf.stroke_bounds
        rows       = (2 + @c_time_end - @c_time_start +1 + @c_extra_rows) * @c_row_division
        columns    = @c_firstcol_division + @c_days.count * @c_col_division

        @pdf.define_grid(:columns => columns, :rows => rows, :gutter => 0)

        # the frames
        @pdf.line_width 1
        mk_entry([0,0],
                 [rows - 1, columns-1], "") # outer frame

        mk_entry([2 * @c_row_division, @c_firstcol_division],
                 [rows - 1 , columns-1], "") # inner frame

        mk_entry([2 * @c_row_division, 0],
                 [rows -1, @c_firstcol_division - 1], "") # left frame

        # the day - line
        row=0;col=@c_firstcol_division
        curday=@c_date_start.to_date

        @c_days.each do |i|

          columnhead="#{i} #{curday.strftime('%d.%m.')}"
          mk_entry([row,col], [row+@c_row_division-1, col+@c_col_division-1], columnhead)
          #require 'pry';binding.pry
          curday=curday+1
          col += @c_col_division
        end

        # the day after line
        row=@c_row_division; col=@c_firstcol_division
        @pdf.line_width 0.75
        @c_days.each do |i|
          mk_entry([row, col], [rows -1, col + @c_col_division - 1], "")
          col+=@c_col_division
        end

        #the  calendar fields
        @pdf.line_width "0.1"
        col=0;row=@c_row_division

        # the rows
        rowlabels=Array(@c_time_start .. @c_time_end).map{|i| "0#{i}.00"[-5..5]}

        a=[" ", rowlabels, [].fill(" ", 0, @c_extra_rows)]
        a.flatten.each do |i|

          # the first column
          # -1 bcause it denotes tha last filled cell, not the next unfilled one
          mk_entry([row,col],[row + @c_row_division - 1, col+@c_firstcol_division - 1], "#{i}")

          # the other columns
          icol=@c_firstcol_division
          (1..7).each do |i|
            mk_entry([row, icol], [row + @c_row_division -1, icol + @c_col_division - 1], " ")
            icol=icol + @c_col_division
          end
          row += @c_row_division
        end

        #yield the block
        instance_eval(&block)
      end
    end
  end
end
