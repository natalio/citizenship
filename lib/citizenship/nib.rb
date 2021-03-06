#see: http://pt.wikipedia.org/wiki/N%C3%BAmero_de_Identifica%C3%A7%C3%A3o_Banc%C3%A1ria
module Citizenship
  def self.valid_nib!(nib, options = {})
    strict = options.fetch(:strict, false)
    bank_codes = ['0007', #BES
                  '0010', #BPI
                  '0018', #Santander
                  '0019', #BBVA
                  '0025', #Caixa BI
                  '0032', #Barclays
                  '0033', #BCP
                  '0034', #BNP Paribas
                  '0035', #CGD
                  '0036', #Montepio
                  '0038', #Banif
                  '0043', #Deutsche Bank
                  '0045', #CA Crédito Agrícola
                  '0046', #Banco Popular
                  '0061', #BiG
                  '0065', #Best
                  '0076', #Finibanco
                  '0079', #BPN
                  '0781', #Direcção Geral do Tesouro
                  '5180'] #Caixa Central de Crédito Agrícola Mútuo

    escaped_nib = strict ? nib : remove_special_chars(nib)
    raise NIBError.new(:size) unless escaped_nib.size == 21
    raise NIBError.new(:invalid_bank_code, bank_code: escaped_nib[0..3]) unless bank_codes.include?(escaped_nib[0..3])

    check_digit = escaped_nib[19..20].to_i
    escaped_nib = escaped_nib[0..18]

    conversion_table = [73, 17, 89, 38, 62, 45, 53, 15, 50, 5, 49, 34, 81, 76, 27, 90, 9, 30, 3]
    sum = (0..18).map do |i|
      escaped_nib.slice(i).to_i * conversion_table[i]
    end.reduce(:+)

    control_number = 98 - sum % 97
    raise NIBError.new(:invalid_check_digit) unless check_digit == control_number
    nib
  end

  def self.valid_nib?(nib, options = {})
    valid_nib!(nib, options)
    true
  rescue NIBError
    false
  end
end