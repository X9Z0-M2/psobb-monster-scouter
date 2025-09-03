import urllib.request
import lxml.html as html
import unicodedata
import re


def plainText(text):
    return unicodedata.normalize("NFKD", text).strip()


def is_int(n):
    try:
        float_n = float(n)
        int_n = int(float_n)
    except ValueError:
        return False
    else:
        return float_n == int_n
    

def parseDropTables(root):
    # look only at dropchart tables

        # <table class="dropcharttbl" bgcolor=#777777>
    dropchart_tables = root.xpath('//table[@class="dropcharttbl"]')
    dctable = {}


    # iter through each html table
    for dropchart_table in dropchart_tables:
        dropchart_row = dropchart_table.xpath('./tr')
        episode_text = plainText(dropchart_row[0].text_content())

        if episode_text in dctable: #since the html tables are iterated over IN ORDER, and the box drop html tables have the same episode text, so rename accordingly
            episode_text = episode_text + " Boxes"
            dctable[episode_text] = {}
        else:
            dctable[episode_text] = {}
        
        Section_IDs = []

        # iter over every cell in the 2nd html table row
        for col, cell in enumerate(dropchart_row[1].xpath('./td')):
            sectionid = plainText(cell.text_content())
            Section_IDs.append(sectionid)
            if sectionid != "": # first cell doesn't contain anything and will be monster/target on subsequent rows
                dctable[episode_text][Section_IDs[col]] = {}

        # iter over every row from 3rd html table row to last row
        for row in range( 2, len(dropchart_row) ):
            dropchart_cell = dropchart_row[row].xpath('./td')
            target = plainText(dropchart_cell[0].text_content()) # first cell is monster/target
            
            if target.upper() == 'GILCHIC/GILCHICH': # check spelling of monster name for fuck up circa ~aug/2024
                target = 'Gillchic/Gillchich'

            if target.upper() == 'DE ROL LE/DAL RAL LIE': # de rol le ultimate isn't RAL its RA
                target = 'DE ROL LE/DAL RA LIE'
            
            if target.upper() == 'VOL OPT/VOL OPT VER. 2': # vol opt ultimate doesn't have a space char ' ' between "ver." and "2".
                target = 'VOL OPT/VOL OPT VER.2'

            # iter over ever cell from 2nd dell to last cell in row
            for col in range( 1, len(dropchart_cell) ):
                drop_names = dropchart_cell[col].xpath('./b')
                if target in dctable[episode_text][Section_IDs[col]]:
                    raise Exception("Duplicate target in same drop table. Update this script to correctly handle this scenario!" + "\n\t\tchart: " + episode_text + "\n\t\ttarget: " + target)
                else:
                    dctable[episode_text][Section_IDs[col]][target] = []

                # note here: we're relying on every drop item text to be in BOLD,
                #            and to have corresponding <abbr> or <sub>|<sup> and they be IN ORDER and they aren't missing or jagged!
                
                    # <td><b>Cannon</b><br>Drop Rate: <sup>1</sup>&frasl;<sub>1820.44</sub><br><br>
                    #     <b>Glaive</b><br>Drop Rate: <sup>1</sup>&frasl;<sub>1820.44</sub><br><br>
                    #     <b>Amplifier of Gibarta</b><br>Drop Rate: <sup>1</sup>&frasl;<sub>1170.29</sub><br><br>
                    # </td>

                for n, cell_drop in enumerate(drop_names):
                    item = plainText(cell_drop.text_content())
                    abbrs = dropchart_cell[col].xpath('./abbr')
                    rare_n = None
                    rare_d = None
                    
                    if item != "":
                        if len(abbrs) > 0:
                            rates = abbrs[n].get('title') # the 'next' line char doesn't print() correctly - only showing the first or last of the two lines
                            dar =  float(plainText( re.search( 'Drop Rate:.*?\((.*?)%\)', rates ).group(1) ))
                            rare_capture = re.search( 'Rare Rate:\s?(.*?)\/(.*?)\s?\((.*?)%\)', rates )
                            rare = float(plainText( rare_capture.group(3) ))
                            
                            sup = dropchart_cell[col].xpath('./sup')
                            sub = dropchart_cell[col].xpath('./sub')
                            
                            if len(sup) == 0 and len(sup) == 0:
                                rare_n = float(plainText( rare_capture.group(1) ))
                                rare_d = float(plainText( rare_capture.group(2) ))
                            else:
                                rare_n = float(plainText(sup[n].text_content())),
                                rare_d = float(plainText(sub[n].text_content())),
                                
                        else:
                            sup = dropchart_cell[col].xpath('./sup')
                            sub = dropchart_cell[col].xpath('./sub')
                            if len(sup) == 0 and len(sup) == 0: # nothing in this table cell
                                dar = 0                         # we ASSUME dar is 0 - meaning there will NEVER be a single drop, but who knows?, its empty!
                                rare = None
                            else: # try to calc rate drop rate
                                dar = 100                       # we ASSUME dar is 100 - there's no explicit value and since there appears to be a rare rate, 
                                                                #                        we ASSUME the monster will always drop something,
                                                                #                        otherwise the RARE rate would be LESS than advertised, but again.. who f-in knows!??!!
                                rare_n = float(plainText(sup[n].text_content()))
                                rare_d = float(plainText(sub[n].text_content()))
                                rare = ( rare_n / rare_d ) * 100

                        dctable[episode_text][Section_IDs[col]][target].append({
                            "item": item,
                            "rare": rare,     # rare when obtained from 'Rare Rate:' has rounding problems and can lead to slightly off calculations
                            "rare_n": rare_n, # for future reference rare_n is not exported if == 1 since it would be redundant.
                            "rare_d": rare_d, # this should be used when calculating the absolute drop chance, assuming available.
                            "dar": dar,       
                                              # keep in mind for ephinea, they have a hidden cap of 7/8 chance, so items will not drop at rates advertised.
                                              # ... this is particularly noticable during boosted drops.
                                              # excerpt: 'A monster's RDR cannot be boosted above 7/8 (87.5%)'
                        })
    return dctable


def writeDropCharts(droptable, filename):
    stringbuilder = "return\n{\n"
    for episode in droptable:
        stringbuilder += '\t["{0}"] = {{\n'.format(episode.upper())
        for sectionid in droptable[episode]:
            stringbuilder += '\t\t["{0}"] = {{\n'.format(sectionid.upper())
            for target in droptable[episode][sectionid]:
                dropcount = len(droptable[episode][sectionid][target])

                if dropcount > 0: # only print targets with drops
                    stringbuilder += """\t\t\t['{0}'] = {{\n""".format(target.replace("'","\\'").upper()) # ' -> \'
                    for num, drop in enumerate(droptable[episode][sectionid][target]):
                        stringbuilder += '\t\t\t\t{\n'
                        stringbuilder += """\t\t\t\t\titem = '{0}',\n""".format(drop["item"].replace("'","\\'")) # ' -> \'

                        if drop["rare"] is None:
                            stringbuilder += '\t\t\t\t\trare = {0},\n'.format("nil") # ~ lua equivalent of None
                        elif is_int(drop["rare"]):
                            stringbuilder += '\t\t\t\t\trare = {0:n},\n'.format(drop["rare"])
                        else:
                            stringbuilder += '\t\t\t\t\trare = {0:0.7g},\n'.format(drop["rare"])
                            
                        if drop["rare_n"] is None:
                            stringbuilder += '\t\t\t\t\trare_n = {0},\n'.format("nil") # ~ lua equivalent of None
                        elif isinstance(drop["rare_n"], (int, float)) and (drop["rare_n"] == 1 or drop["rare_n"] == 1.0):
                            #stringbuilder += '\t\t\t\t\trare_n = {0:n},\n'.format(drop["rare_n"])
                            pass
                        else:
                            stringbuilder += '\t\t\t\t\trare_n = {0:0.7g},\n'.format(drop["rare_n"])
                            
                        if drop["rare_d"] is None:
                            stringbuilder += '\t\t\t\t\trare_d = {0},\n'.format("nil") # ~ lua equivalent of None
                        elif is_int(drop["rare_d"]):
                            stringbuilder += '\t\t\t\t\trare_d = {0:n},\n'.format(drop["rare_d"])
                        else:
                            stringbuilder += '\t\t\t\t\trare_d = {0:0.7g},\n'.format(drop["rare_d"])

                        if is_int(drop["dar"]):
                            stringbuilder += '\t\t\t\t\tdar = {0:n}\n'.format(drop["dar"])
                        else:
                            stringbuilder += '\t\t\t\t\tdar = {0:0.7g}\n'.format(drop["dar"])

                        if dropcount > 1 and dropcount != num:
                            stringbuilder += '\t\t\t\t},\n'
                        else:
                            stringbuilder += '\t\t\t\t}\n'
                    stringbuilder += '\t\t\t},\n'

            stringbuilder += '\t\t},\n'
        stringbuilder += '\t},\n'
    stringbuilder += "}\n"

    f = open(filename, "w")
    f.write(stringbuilder)
    f.close()


def main():
    difficulties = ["normal","hard","very-hard","ultimate"]
    #difficulties = ["normal"]

    for diff in difficulties:
        print("Retrieving Drop Chart:", diff)
        request_url = urllib.request.urlopen('https://ephinea.pioneer2.net/drop-charts/' + diff)
        root = html.parse(request_url)

        droptable = parseDropTables(root)
        writeDropCharts(droptable, "../Monster Scouter/Drops/" + diff + ".lua")


if __name__ == "__main__":
    main()

