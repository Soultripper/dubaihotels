#coding: utf-8
module Currency
  extend self

    def codes
      {
        GB: [:GBP, '£'],
        US: [:USD, '$'],
        EU: [:EUR, '€'],        
        AE: [:AED, 'AED'],
        AR: [:ARS, '$'],
        AU: [:AUD, 'AU$'],
        BG: [:BGN, 'лв'],
        BR: [:BRL, 'R$'],
        CA: [:CAD, 'C$'],
        CH: [:CHF, 'CHF'],
        CL: [:CLP, '$'],
        CN: [:CNY, '¥'],
        CO: [:COP, '$'],
        CZ: [:CZK, 'Kč'],
        DK: [:DKK, 'kr'],
        EG: [:EGP, 'EGP'],
        HK: [:HKD, '$'],
        HR: [:HRK, 'kn'],
        HU: [:HUF, 'Ft'],
        IN: [:INR, 'Rs.'],
        JP: [:YEN, '¥'],
        KR: [:KRW, '₩'],
        MA: [:MAD, 'MAD'],#
        MX: [:MXN, '$'],
        MY: [:MYR, 'RM'],
        NO: [:NOK, 'kr'],
        NZ: [:NZD, '$'],
        PE: [:PEN, 'PEN'], # peru
        PL: [:PLN, 'zł'],
        RO: [:RON, 'RON'],
        RS: [:RSD, 'RSD'],
        RU: [:RUB, 'py6'],
        SA: [:SAR, 'SR'],
        SE: [:SEK, 'kr'],
        SG: [:SGD, '$'],
        TH: [:THB, '฿'],
        TN: [:TND, 'TND'], # Tunisia
        TR: [:TRY, 'TL'],
        ZA: [:ZAR, 'R']
      }
    end


    def find_by_currency(code)
      codes.select {|k,v| v[0] == code.to_sym}.first
    end


end

