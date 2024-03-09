using Toybox.Lang;

typedef Phone as Lang.Dictionary<Lang.String, Lang.String or Lang.Number>;
typedef Phones as Lang.Array<Phone>;

(:background)
function phoneForNumber(number as Lang.String or Null) as Phone {
    var phones = getPhones();
    for (var i = 0; i < phones.size(); i++) {
        if((phones[i]["number"] as Lang.String).equals(number)) {
            return phones[i];
        }
    }
    var adjustedNumber;
    if (number != null) {
        adjustedNumber = number;
    } else {
        adjustedNumber = "";
    }
    return {
        "number" => adjustedNumber,
        "id" => -2
    };
}
