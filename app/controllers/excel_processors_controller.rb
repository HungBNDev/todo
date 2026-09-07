class ExcelProcessorsController < ApplicationController
  allow_unauthenticated_access

  def new
  end

  def create
    goc_file = params[:goc_file]
    kh_file = params[:kh_file]

    unless goc_file && kh_file
      flash.now[:alert] = "Please upload both GOC.xlsx and KH.xlsx"
      render :new, status: :unprocessable_entity
      return
    end

    begin
      # Read KH.xlsx
      kh_workbook = RubyXL::Parser.parse(kh_file.tempfile.path)
      kh_sheet = kh_workbook[0]

      kh_header = kh_sheet[0].cells.map { |c| c&.value.to_s.strip }
      ma_khang_index_kh = kh_header.index("MA_KHANG")

      unless ma_khang_index_kh
        flash.now[:alert] = "Missing MA_KHANG column in KH.xlsx"
        render :new, status: :unprocessable_entity
        return
      end

      kh_ma_khang_values = Set.new
      kh_sheet.each_with_index do |row, i|
        next if i == 0 || row.nil?
        cell = row[ma_khang_index_kh]
        kh_ma_khang_values << cell.value.to_s.strip if cell && cell.value
      end

      # Read GOC.xlsx
      goc_workbook = RubyXL::Parser.parse(goc_file.tempfile.path)
      goc_sheet = goc_workbook[0]

      goc_header = goc_sheet[0].cells.map { |c| c&.value.to_s.strip }
      ma_khang_index_goc = goc_header.index("MA_KHANG")
      ma_sogcs_index_goc = goc_header.index("MA_SOGCS")

      unless ma_khang_index_goc && ma_sogcs_index_goc
        flash.now[:alert] = "Missing MA_KHANG or MA_SOGCS column in GOC.xlsx"
        render :new, status: :unprocessable_entity
        return
      end

      processed_data = []

      # header
      header_vals = []
      goc_sheet[0].cells.each { |c| header_vals << (c ? c.value : nil) }
      header_vals << "PHIEN"
      processed_data << header_vals

      phien_index_goc = header_vals.size - 1

      # 1. Extract data to an array
      raw_goc_data = []
      goc_sheet.each_with_index do |row, i|
        next if i == 0 || row.nil?

        row_vals = []
        row.cells.each { |c| row_vals << (c ? c.value : nil) }
        raw_goc_data << row_vals
      end

      # 2. Iterate the array to process
      raw_goc_data.each do |row_vals|
        cell_val = row_vals[ma_khang_index_goc]
        cell_val = cell_val ? cell_val.to_s.strip : nil

        unless kh_ma_khang_values.include?(cell_val)
          ma_sogcs_val = row_vals[ma_sogcs_index_goc]
          ma_sogcs_val = ma_sogcs_val ? ma_sogcs_val.to_s.strip : ""
          phien_val = ma_sogcs_val[0..1]

          row_vals[phien_index_goc] = phien_val
          processed_data << row_vals
        end
      end

      # Rebuild using a new workbook to avoid slow row deletion
      new_workbook = RubyXL::Workbook.new
      new_sheet = new_workbook[0]

      processed_data.each_with_index do |row_vals, row_idx|
        row_vals.each_with_index do |val, col_idx|
          new_sheet.add_cell(row_idx, col_idx, val) unless val.nil?
        end
      end

      file_name = "da_xy_ly_GOC_#{Time.now.to_i}.xlsx"
      downloads_dir = Rails.public_path.join("downloads")
      FileUtils.mkdir_p(downloads_dir)

      file_path = downloads_dir.join(file_name)
      File.binwrite(file_path, new_workbook.stream.string)

      @download_url = "/downloads/#{file_name}"
      flash.now[:notice] = "Processing complete! Click the button below to download."
      render :new
    rescue => e
      flash.now[:alert] = "An error occurred: #{e.message}"
      render :new, status: :unprocessable_entity
    end
  end
end
