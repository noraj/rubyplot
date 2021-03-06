module Rubyplot
  module Artist
    class Figure < Artist::Base
      DEFAULT_CANVAS_DIM = 40.0
      
      # Title on the figure.
      attr_reader :title
      # Number of Axes objects in the rows.
      attr_reader :nrows
      # Number of Axes objects in the cols.
      attr_reader :ncols
      # Total width of the Figure in pixels.
      attr_reader :width
      # Total height of the Figure in pixels.
      attr_reader :height
      # Ratio of the total height that is the spacing between the top of the
      #   Figure and the top of the Axes.
      attr_reader :top_spacing
      # Ratio of the total width that is the spacing between the left of the
      #   Figure and the left of the Axes.
      attr_reader :left_spacing
      # Ratio of the total width that is the spacing between the right of the
      #   Figure and the right of the Axes.
      attr_reader :right_spacing
      # Ratio of the total width that is the spacing between the bottom of the
      #   Figure and the bottom of the Axes.
      attr_reader :bottom_spacing
      attr_reader :theme_options
      attr_reader :marker_color
      # Font color specified as a Symbol from Rubyplot::COLOR::COLOR_INDEX.
      attr_reader :font_color
      # Unit of the figure size.
      attr_reader :figsize_unit
      # Max X co-ordinate in terms of Rubyplot Co-ordinate System.
      attr_reader :max_x
      # Max Y co-ordinate in terms of Rubyplot Co-ordinate System.
      attr_reader :max_y
      # Min X co-ordinate in terms of Rubyplot Co-ordinate System.
      attr_reader :min_x
      # Min Y co-ordinate in terms of Rubyplot Co-ordinate System.
      attr_reader :min_y

      # Initialize a Rubyplot::Artist::Figure object.
      # @param height [Integer] nil Height in pixels of the complete Figure.
      # @param width [Integer] nil Width in pixels of the complete Figure.
      def initialize(height: nil, width: nil, figsize_unit: :cm)
        super(0, 0)
        @title = ''
        @nrows = 1
        @ncols = 1
        @width = (width || DEFAULT_CANVAS_DIM).to_f
        @height = (height || DEFAULT_CANVAS_DIM).to_f
        @top_spacing = 5
        @bottom_spacing = 5
        @left_spacing = 5
        @right_spacing = 5
        @subplots = nil
        @figsize_unit = figsize_unit
        set_rubyplot_artist_coords!
        setup_default_theme
        add_subplots! @nrows, @ncols
      end

      # Create space for subplots to be added to the figure.
      #
      # @param nrows [Integer] Number of rows to add.
      # @param ncols [Integer] Number of cols to add.
      def add_subplots!(nrows, ncols)
        @nrows = nrows
        @ncols = ncols
        @subplots = Array.new(@nrows) { Array.new(@ncols) { nil } }
      end

      # Actually create a subplot at position (nrow, ncol) on the figure.
      # You must call `add_subplots` and create space in the figure before
      # calling this method. Returns the created Rubyplot::Axes object.
      # 
      # @param nrow [Integer] X co-ordinate of the subplot.
      # @param ncol [Integer] Y co-ordinate of the subplot.
      def add_subplot!(nrow, ncol)
        # FIXME: make this work for mutliple subplots.
        plottable_width = (@max_x - (@left_spacing + @right_spacing)).to_f
        plottable_length = (@max_y - (@top_spacing + @bottom_spacing)).to_f
        @subplots[nrow][ncol] = Rubyplot::Artist::Axes.new(
          self,
          abs_x: @left_spacing + (plottable_width / @ncols) * ncol,
          abs_y: @bottom_spacing + (plottable_length / @nrows) * nrow,
          width: plottable_width / @ncols,
          height: plottable_length / @nrows
        )
        @subplots[nrow][ncol]
      end

      # Draw on a canvas and output to a file.
      #
      # @param file_name [String] File name to output to.
      def write(file_name, device: :file)
        print_on_device(file_name, device)
      end

      def show
        Rubyplot.backend.output_device = Rubyplot.iruby_inline ? :iruby : :window
        print_on_device(nil, Rubyplot.backend.output_device)
      end

      private

      def print_on_device(file_name, device)
        Rubyplot.backend.canvas_height = @height
        Rubyplot.backend.canvas_width = @width
        Rubyplot.backend.figure = self
        Rubyplot.backend.init_output_device(file_name, device: device)
        @subplots.each { |i| i.each(&:process_data) }
        @subplots.each { |i| i.each(&:draw) }
        Rubyplot.backend.show
        Rubyplot.backend.stop_output_device
      end

      def set_rubyplot_artist_coords!
        @max_x = 100.0
        @max_y = 100.0
        @min_x = 0.0
        @min_y = 0.0
        if @height > @width
          aspect_ratio = @height / @width
          @max_y = @max_y * aspect_ratio
        elsif @height < @width
          aspect_ratio = @width / @height
          @max_x = @max_x * aspect_ratio
        end
      end

      def setup_default_theme
        defaults = {
          marker_color: :white,
          font_color: :black,
          background_image: nil
        }
        @theme_options = defaults.merge Themes::CLASSIC_WHITE
        @marker_color = @theme_options[:marker_color]
        @font_color = @theme_options[:font_color] || @marker_color
      end
    end # class Figure
  end # module Artist
end # module Rubyplot
