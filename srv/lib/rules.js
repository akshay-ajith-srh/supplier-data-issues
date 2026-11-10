const POSTAL = {
  DE: /^\d{5}$/, FR: /^\d{5}$/, ES: /^\d{5}$/,
  NL: /^\d{4}\s?[A-Z]{2}$/, US: /^\d{5}(-\d{4})?$/, JP: /^\d{3}-?\d{4}$/,
  GB: /^[A-Z]{1,2}\d[A-Z\d]?\s?\d[A-Z]{2}$/i
}

// addr uses these names: StreetName, HouseNumber, PostalCode, CityName, Country
function check(ruleID, addr) {
  if (!addr) return { passed: false, currentValue: null }
  switch (ruleID) {
    case 'POSTAL_FORMAT': {
      const v = (addr.PostalCode || '').trim()
      const re = POSTAL[addr.Country]
      return { passed: !!re && re.test(v), currentValue: v }
    }
    case 'STREET_MISSING': {
      const v = (addr.StreetName || '').trim()
      return { passed: v.length > 0, currentValue: v }
    }
    case 'HOUSE_NUMBER_FORMAT': {
      const v = (addr.HouseNumber || '').trim()
      return { passed: /^\d+\s?[A-Za-z]?([-/]\d+[A-Za-z]?)?$/.test(v), currentValue: v }
    }
    case 'COUNTRY_CODE_VALID': {
      const v = (addr.Country || '').trim()
      return { passed: /^[A-Z]{2}$/.test(v), currentValue: v }
    }
    case 'CITY_NAME_CHECK': {
      const v = (addr.CityName || '').trim()
      return { passed: v.length > 1 && !/\d/.test(v), currentValue: v }
    }
    default: return { passed: false, currentValue: null }
  }
}
export { check }