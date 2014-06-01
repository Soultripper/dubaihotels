#coding: utf-8
module Currency
  extend self

    # def codes
    #   {
    #     USD: '$',
    #     EUR: '€',
    #     GBP: '£',
    #     AED: 'د.',
    #     ARS: '$',
    #     AUD: 'AU$',
    #     BGN: 'лв',
    #     BRL: 'R$',
    #     CAD: 'C$',
    #     CHF: 'CHF',
    #     CLP: '$',
    #     CNY: '¥',
    #     COP: '$',
    #     CZK: 'Kč',
    #     DKK: 'kr',
    #     DZD: 'DZD',
    #     EGP: 'EGP',
    #     HKD: '$',
    #     HRK: 'HRK',
    #     HUF: 'Ft',
    #     INR: 'Rs.',
    #     # JPN: '円',
    #     KRW: 'W',
    #     MAD: 'MAD',
    #     MXN: '$',
    #     MYR: 'RM',
    #     NOK: 'kr',
    #     NZD: 'NZ$',
    #     PEN: 'PEN',
    #     PLN: 'PLN',
    #     RON: 'RON',
    #     RSD: 'RSD',
    #     RUB: 'py6',
    #     SAR: 'SAR',
    #     SEK: 'kr',
    #     SGD: '$',
    #     THB: '฿',
    #     TND: 'TND',
    #     TRY: 'TL',
    #     ZAR: 'R'
    #   }
    # end

    def codes
      {
        GB: [:GBP, '£'],
        US: [:USD, '$'],
        EU: [:EUR, '€'],        
        AE: [:AED, 'د.'],
        AR: [:ARS, '$'],
        AU: [:AUD, '$'],
        BG: [:BGN, 'лв'],
        BR: [:BRL, 'R$'],
        CA: [:CAD, 'C$'],
        CH: [:CHF, 'Fr'],
        CL: [:CLP, '$'],
        CN: [:CNY, '¥'],
        CO: [:COP, '$'],
        CZ: [:CZK, 'Kč'],
        DK: [:DKK, 'kr'],
        DZ: [:DZD, 'د.ج'],
        EG: [:EGP, 'ج.م'],
        HK: [:HKD, '$'],
        HR: [:HRK, 'kn'],
        HU: [:HUF, 'Ft'],
        IN: [:INR, '₹'],
        JP: [:YEN, '円'],
        KR: [:KRW, '₩'],
        MA: [:MAD, 'د.م.'],
        MX: [:MXN, '$'],
        MY: [:MYR, 'RM'],
        NO: [:NOK, 'kr'],
        NZ: [:NZD, '$'],
        PE: [:PEN, 'S/.'],
        PL: [:PLN, 'zł'],
        RO: [:RON, 'L'],
        RS: [:RSD, 'РСД'],
        RU: [:RUB, 'py6'],
        SA: [:SAR, 'ر.س'],
        SE: [:SEK, 'kr'],
        SG: [:SGD, '$'],
        TH: [:THB, '฿'],
        TN: [:TND, 'د.ت'],
        TR: [:TRY, 'TL'],
        ZA: [:ZAR, 'R']
      }
    end

    def find_by_currency(code)
      codes.select {|k,v| v[0] == code.to_sym}.first
    end


end

