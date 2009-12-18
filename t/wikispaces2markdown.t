#!/usr/bin/env perl
use strict;
use warnings;
use Text::Wikispaces2Markdown;

use Test::More tests => 1;
use Test::Differences;

#--- Basic functionality --------------------------------------------
my $content = <<WIKISPACES;
=Car Buyer's Guide=

So you want a buy a car... welcome to the world of options.

If you're looking for a car that leaves others in the dust at the red light, this guide is not for you. I don't care about showing off in a car or [[http://youtube.com/watch?v=nhzFU0Crleo|roasting tires]]. I do care about staying alive if one of those who do show off, hits my car.

I wrote the guide below for myself, while I was shopping for a new car. I hope it helps you too.

==Criteria, in order of priority==

# Safety
** "Whiplash injuries account for approximately 60 per cent of all personal injuries caused by car crashes." - [[http://www.folksam.se/english/reports|Folksam - How safe is your car, 2007]]
** 200,000 medically serious whiplash injuries per year in US - [[http://www.consumerreports.org/cro/cars/car-safety/car-safety-reviews/rear-collisions-8-07/overview/0708_collide_ov.htm|Consumer Reports]]
# Reliability
# Ergonomics
# Cost of ownership


==Sources for safety ratings==

* [[http://informedforlife.org/|InformedForLife.org - SCORE]]
* [[http://www.iihs.org/ratings/default.aspx|IIHS]]
* NHTSA - the star-rating [[http://www.safercar.gov/vgn-ext-templating/v/index.jsp?vgnextoid=c276c95372935110VgnVCM1000002fd17898RCRD|brochures]], or if you're a maniac, the [[http://www-nrd.nhtsa.dot.gov/database/aspx/vehdb/queryvehicle.aspx|raw reports]]. Note that NHTSA's "4-STARS is typically 3x risk vs. 5-STARS" (according to [[http://www.informedforlife.org/viewartcl.php?index=23|Informed for LIFE]]).
* [[http://translate.google.com/translate?u=http%3A%2F%2Fwww.adac.de%2FTests%2FCrash_Tests%2FAutomodelle%2Fdefault.asp%3FComponentID%3D87715%26SourcePageID%3D8645&hl=en&ie=UTF8&sl=de&tl=en|Germany's ADAC]] - mostly European cars (e.g. no Lexus). All information seems to show up in EuroNCAP as well, but without mention of model years, AND with slight differences (see EuroNCAP below). [why didn't ADAC use English so the whole world can benefit from this, literally, life-saving information?]
* [[http://www.euroncap.com/testresults.aspx|EuroNCAP]] - see ADAC above for model years. For example, EuroNCAP's [[http://www.euroncap.com/carsearch.aspx?make=ef018b8a-892c-4abb-92b0-24103a2c81be|Audi A4 2001]] represents ADAC's [[http://translate.google.com/translate?u=http%3A%2F%2Fwww.adac.de%2FTests%2FCrash_Tests%2FAutomodelle%2Fcrashtest_audi_a4.asp%3FComponentID%3D4645%26SourcePageID%3D8650&hl=en&ie=UTF8&sl=de&tl=en|Audi A4 2002-2004]], **but** note the slight difference in protection for the driver, possibly due to steering wheel placement (right vs. left side). Doesn't test for whiplash injuries.
* [[http://www.ancap.com.au/|Australian New Car Assessment Program]] - doesn't test rear impact (whiplash injury)
* [[http://www.nasva.go.jp/mamoru/english|Japan's National Agency for Automotive Safety and Victims' Aid]] - only Japanese cars; bad user interface; star ratings from 1 to 6
* [[http://www.folksam.se/english/reports|Folksam Insurance, Sweden]] - aggregates EuroNCAP and includes "the results of two independent car seat tests carried out by Folksam/National Road Administration and IIWPG (an international association in the insurance sector)"


==Sources for reliability==

* [[http://consumerreports.org/|Consumer Reports]] (CR) - subscription required
* [[http://www.jdpower.com/autos/used-cars|JDPower]]
* MSN Auto - uninformative (almost all vehicles have 5/5 ratings)


The following are the cars from InformedForLife's SCORE ranking list for 2008 that ranked 65 points or under (the safest level). Any vehicle that had a 'Marginal' or worse ratings by IIHS or EuroNCAP, in any of the front, side or rear crash tests has been removed.

=Approved vehicles=

==[[#Audi_A4_mfg_after_2005_Nov]] Audi A4, mfg. after 2005 Nov==

===[[#Safety]] Safety===
* [[http://www.iihs.org/ratings/head_restraints/headrestraints.aspx?audi|IIHS rear]]: 2006 (mfg after Nov. 2005): A, A, G; 2007 (mfg. before Aug 2006): A, A, A; 2007-2008 (mfg. after July 2006): G, G, G
* [[http://www.iihs.org/ratings/ratingsbyseries.aspx?id=558|IIHS]] front: G; side: G, A cage
* NHTSA 2006-2008: 4,4, 5,4, 4
* [[http://www.euroncap.com/tests/audi_a4_2001/88.aspx|EuroNCAP]] 2001: marginal driver chest, pelvis, Good rest; Good side
* Folksam: whiplash protection "approved", 2001-2007
===[[#Reliability]] Reliability===
* [[http://www.consumerreports.org/cro/cars/models/used/audi/a4/reliability.htm|CR]]: Audi A4, 4-cylinder: apparently very good, but for some reason the "used car" prediction is average
* [[http://www.jdpower.com/autos/Audi/A4/2007/Sedan/ratings|JDPower]] predicted reliability: 2/5; quality: around 3/5
===[[#Ergonomics]] Ergonomics===
* extremely responsive brakes; brakes too much when lightly pushing the brakes
* rear seats fold nicely; can almost take a nap in the resulting trunk
* good room in the back seat
* + no ancient wood-trim
* - ride less smooth than Lexus
* - less quiet than Lexus
* - no aux audio input
* + good ergonomics for mirror adjustment (from driver's position)
* - mediocre/ugly instrument panel lighting
* [[http://www.consumerreports.org/cro/cars/past-road-test/sports-sedans-506/audi-a4/index.htm|CR's road test]]
===[[#Cost]] Cost===
* [[http://www.consumerreports.org/cro/cars/models/used/audi/a4/ratings-and-specs.htm|CR mpg city/hwy]] 16/34
WIKISPACES

my $markdown = Text::Wikispaces2Markdown::convert($content);
eq_or_diff($markdown, <<'MARKDOWN', 'comprehensive test', {max_width => 120});
# Car Buyer's Guide

So you want a buy a car... welcome to the world of options.

If you're looking for a car that leaves others in the dust at the red light, this guide is not for you. I don't care about showing off in a car or [roasting tires](http://youtube.com/watch?v=nhzFU0Crleo). I do care about staying alive if one of those who do show off, hits my car.

I wrote the guide below for myself, while I was shopping for a new car. I hope it helps you too.

## Criteria, in order of priority

1. Safety
    * "Whiplash injuries account for approximately 60 per cent of all personal injuries caused by car crashes." - [Folksam - How safe is your car, 2007](http://www.folksam.se/english/reports)
    * 200,000 medically serious whiplash injuries per year in US - [Consumer Reports](http://www.consumerreports.org/cro/cars/car-safety/car-safety-reviews/rear-collisions-8-07/overview/0708_collide_ov.htm)
1. Reliability
1. Ergonomics
1. Cost of ownership


## Sources for safety ratings

* [InformedForLife.org - SCORE](http://informedforlife.org/)
* [IIHS](http://www.iihs.org/ratings/default.aspx)
* NHTSA - the star-rating [brochures](http://www.safercar.gov/vgn-ext-templating/v/index.jsp?vgnextoid=c276c95372935110VgnVCM1000002fd17898RCRD), or if you're a maniac, the [raw reports](http://www-nrd.nhtsa.dot.gov/database/aspx/vehdb/queryvehicle.aspx). Note that NHTSA's "4-STARS is typically 3x risk vs. 5-STARS" (according to [Informed for LIFE](http://www.informedforlife.org/viewartcl.php?index=23)).
* [Germany's ADAC](http://translate.google.com/translate?u=http%3A%2F%2Fwww.adac.de%2FTests%2FCrash_Tests%2FAutomodelle%2Fdefault.asp%3FComponentID%3D87715%26SourcePageID%3D8645&hl=en&ie=UTF8&sl=de&tl=en) - mostly European cars (e.g. no Lexus). All information seems to show up in EuroNCAP as well, but without mention of model years, AND with slight differences (see EuroNCAP below). [why didn't ADAC use English so the whole world can benefit from this, literally, life-saving information?]
* [EuroNCAP](http://www.euroncap.com/testresults.aspx) - see ADAC above for model years. For example, EuroNCAP's [Audi A4 2001](http://www.euroncap.com/carsearch.aspx?make=ef018b8a-892c-4abb-92b0-24103a2c81be) represents ADAC's [Audi A4 2002-2004](http://translate.google.com/translate?u=http%3A%2F%2Fwww.adac.de%2FTests%2FCrash_Tests%2FAutomodelle%2Fcrashtest_audi_a4.asp%3FComponentID%3D4645%26SourcePageID%3D8650&hl=en&ie=UTF8&sl=de&tl=en), **but** note the slight difference in protection for the driver, possibly due to steering wheel placement (right vs. left side). Doesn't test for whiplash injuries.
* [Australian New Car Assessment Program](http://www.ancap.com.au/) - doesn't test rear impact (whiplash injury)
* [Japan's National Agency for Automotive Safety and Victims' Aid](http://www.nasva.go.jp/mamoru/english) - only Japanese cars; bad user interface; star ratings from 1 to 6
* [Folksam Insurance, Sweden](http://www.folksam.se/english/reports) - aggregates EuroNCAP and includes "the results of two independent car seat tests carried out by Folksam/National Road Administration and IIWPG (an international association in the insurance sector)"


## Sources for reliability

* [Consumer Reports](http://consumerreports.org/) (CR) - subscription required
* [JDPower](http://www.jdpower.com/autos/used-cars)
* MSN Auto - uninformative (almost all vehicles have 5/5 ratings)


The following are the cars from InformedForLife's SCORE ranking list for 2008 that ranked 65 points or under (the safest level). Any vehicle that had a 'Marginal' or worse ratings by IIHS or EuroNCAP, in any of the front, side or rear crash tests has been removed.

# Approved vehicles

## Audi A4, mfg. after 2005 Nov

### Safety

* [IIHS rear](http://www.iihs.org/ratings/head_restraints/headrestraints.aspx?audi): 2006 (mfg after Nov. 2005): A, A, G; 2007 (mfg. before Aug 2006): A, A, A; 2007-2008 (mfg. after July 2006): G, G, G
* [IIHS](http://www.iihs.org/ratings/ratingsbyseries.aspx?id=558) front: G; side: G, A cage
* NHTSA 2006-2008: 4,4, 5,4, 4
* [EuroNCAP](http://www.euroncap.com/tests/audi_a4_2001/88.aspx) 2001: marginal driver chest, pelvis, Good rest; Good side
* Folksam: whiplash protection "approved", 2001-2007

### Reliability

* [CR](http://www.consumerreports.org/cro/cars/models/used/audi/a4/reliability.htm): Audi A4, 4-cylinder: apparently very good, but for some reason the "used car" prediction is average
* [JDPower](http://www.jdpower.com/autos/Audi/A4/2007/Sedan/ratings) predicted reliability: 2/5; quality: around 3/5

### Ergonomics

* extremely responsive brakes; brakes too much when lightly pushing the brakes
* rear seats fold nicely; can almost take a nap in the resulting trunk
* good room in the back seat
* + no ancient wood-trim
* - ride less smooth than Lexus
* - less quiet than Lexus
* - no aux audio input
* + good ergonomics for mirror adjustment (from driver's position)
* - mediocre/ugly instrument panel lighting
* [CR's road test](http://www.consumerreports.org/cro/cars/past-road-test/sports-sedans-506/audi-a4/index.htm)

### Cost

* [CR mpg city/hwy](http://www.consumerreports.org/cro/cars/models/used/audi/a4/ratings-and-specs.htm) 16/34
MARKDOWN
