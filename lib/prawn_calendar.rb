require "prawn_calendar/version"
require 'prawn'
require 'time'
require 'date'


module Prawn
  class Document

    # Defines the grid system for a particular document.  Takes the number of
    # rows and columns and the width to use for the gutter as the
    # keys :rows, :columns, :gutter, :row_gutter, :column_gutter
    #
    def define_grid(options = {})
      @grid = Grid.new(self, options)
      @boxes = nil  # see 
    end
  end
end

module PrawnCalendar

  class WeeklyCalendar
    attr_accessor :pdf           # the Prawn instance
    attr_accessor :c_date_start


    def c_date_start=(day)
      d = DateTime.iso8601(day)
      # note that we start the week on monday
      # compute the beginning of the week
      @c_date_start = (d -(d-1).wday).to_time
      @c_date_end   = (@c_date_start.to_date + 6).to_time

    end

    def initialize(pdf, &block)
      @pdf=pdf

      @c_date_start        = (d=DateTime.now;d-(d-1).wday).to_time  # its a monday
      @c_date_end          = @c_date_start+6
      @c_time_start        = 8
      @c_time_end          = 22
      @c_entry_gutter      = 1
      @c_annotation_gutter = 2
      @c_corner_radius     = 1
      @c_row_division      = 4
      @c_col_division      = 5
      @c_firstcol_division = 2
      @c_fontsize          = 8
      @c_wday_corrector    = 2
      @c_days              = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
      @c_extra_rows        = 3

      yield(self) if block_given?
    end

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
    end


    def cal_entry(starttime, endtime, text)
      time_to_start = Time.iso8601(starttime).localtime
      time_to_end = Time.iso8601(endtime).localtime

      a= ((@c_date_start.to_time .. @c_date_end.to_time).cover?(time_to_start))
      puts "datum ausserhalb des Kalenders #{@c_date_start} < #{time_to_start} < #{@c_date_end} #{text}" if a==false

      hour_to_start = time_to_start.hour
      hour_to_end   = time_to_end.hour
      min_to_start  = time_to_start.min / (60/@c_row_division)
      min_to_end    = time_to_end.min / (60/@c_row_division)

      starttime_s   = time_to_start.strftime("%k.%M")
      endtime_s     = time_to_end.strftime("%k.%M")

      text_to_show  = "#{starttime_s} - #{endtime_s}<br/>#{text}"

      day    = (time_to_start.wday + 6) % 7  # since we start on monday shift it one left
      column = @c_firstcol_division + day * @c_col_division

      srow = 2 * @c_row_division + (hour_to_start - @c_time_start) * @c_row_division + min_to_start
      erow = 2 * @c_row_division + (hour_to_end - @c_time_start) * @c_row_division -1 + min_to_end

      cal_entry_raw([srow, column], erow - srow, text_to_show)
    end

    def cal_entry_raw(ll, length, text)
      width=4
      ur=[ll[0]+length, ll[1]+width]
      @pdf.grid(ll,ur).bounding_box do
        #@pdf.stroke_bounds
        @pdf.fill_color "7fdf7f"
        @pdf.line_width 0.1

        corner=1
        @pdf.rounded_rectangle([corner, @pdf.bounds.height - corner], # startpoint
                               @pdf.bounds.width  - 2* corner, # width
                               @pdf.bounds.height - 2* corner, # height
                               2 * corner                 # radius
                               )
        @pdf.fill_and_stroke
        #require 'pry';binding.pry if text.match(/.*cc.*/)

        @pdf.fill_color "000000"
        excess_text = @pdf.text_box "#{ll} #{ur} #{text}",
          :at => [2*corner, @pdf.bounds.height- 2*corner],
          :width    => @pdf.bounds.width-4*corner,
          :height   => @pdf.bounds.height-4*corner,
          :overflow => :truncate,
          :kerning => true,
          :inline_format => true,
          :size     => 9
      end
    end



    def mk_calendar(ll, opts, &block)
      puts opts
      @pdf.bounding_box(ll, width: opts[:width], height: opts[:height]) do
        @pdf.stroke_bounds
        rows       = (@c_time_end - @c_time_start + 2) * @c_row_division
        columns    = @c_firstcol_division + @c_days.count * @c_col_division

        @pdf.define_grid(:columns => columns, :rows => rows, :gutter => 0)

        # the frames
        @pdf.line_width 1
        mk_entry([0,0],[@c_row_division + rows - 1, columns-1], "") # outer frame

        mk_entry([2 * @c_row_division, @c_firstcol_division],
                 [@c_row_division + rows - 1 , columns-1], "") # inner frame

        mk_entry([2 * @c_row_division, 0],[@c_row_division + rows -1, @c_firstcol_division - 1], "") # left frame

        # the day - line
        row=0;col=@c_firstcol_division
        curday=@c_date_start.to_date

        @c_days.each do |i|
          mk_entry([row,col], [row+@c_row_division-1, col+@c_col_division-1], "#{i} #{curday.strftime('%d.%m.')}")
          curday=curday+1
          col += @c_col_division
        end

        # the day after line
        row=@c_row_division;col=@c_firstcol_division
        @pdf.line_width 0.75
        @c_days.each do |i|
          mk_entry([row, col], [@c_row_division + rows -1, col + @c_col_division - 1], "")
          col+=@c_col_division
        end

        #the  calendar fields
        @pdf.line_width "0.1"
        col=0;row=@c_row_division

        # the rows
        rowlabels=Array(@c_time_start .. @c_time_end).map{|i| "0#{i}.00"[-5..5]}
        ["", rowlabels, [].fill("", 0, @c_extra_rows)].flatten.each do |i|

          # the first column
          mk_entry([row,col],[row + @c_row_division - 1, col+@c_firstcol_division - 1], "#{i}")

          # the other columns
          icol=@c_firstcol_division
          (1..7).each do |i|
            mk_entry([row, icol], [row + @c_row_division -1, icol + @c_col_division - 1], "")
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
