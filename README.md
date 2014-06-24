# Resident

Validates a National Identification Number (See http://en.wikipedia.org/wiki/National_identification_number).
There are some 62 countries that have this type of number.
This gem currently only supports Swedish (Personnummer) and Finnish (Henkilöasiakkaat) ones.

There is a special focus on identifying these numbers robustly (i.e. you can safely validate a param[:number] directly, or cleanup your database by running every non-normalized value through this gem).

## Installation

    gem install resident

## Usage

Really, you can just use <tt>valid?</tt>, <tt>to_s</tt>, and <tt>age</tt> like so:

    require 'resident'

    number = NationalIdentificationNumber::Swedish.new('0501261853')

    number.valid?  #=> true
    number.to_s    #=> "050126-1853"
    number.age     #=> 9

Please have a look at the specs to see how the national identification numbers of various countries are handled.

An example of robustness:

    NationalIdentificationNumber::Swedish.new("19050126-185d3\n").to_s => "050126-1853"

## License

Some marked parts of the code are inspired or taken from MIT licensed code of

* Peter Hellberg https://github.com/c7/personnummer/blob/master/lib/personnummer.rb
* Henrik Nyh http://henrik.nyh.se

Other than that you got:

Copyright (c) 2011-2014 Bukowskis.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.