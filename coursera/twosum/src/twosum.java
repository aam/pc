/**
 * Created by apreleal on 6/12/2014.
 */

import java.io.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;

public class twosum {
    public static void main(String[] args) {
        HashSet<Long> values = new HashSet<Long>();
        java.io.File f = new File("d:\\coursera\\algo1-programming_prob-2sum.txt");
        try {
            BufferedReader br = new BufferedReader(new FileReader(f));
            while(true) {
                String s = br.readLine();
                if (s == null) {
                    break;
                }
                values.add(Long.parseLong(s));
            }
        } catch (FileNotFoundException fe) {
            System.out.println("Failed to read the file:" + fe);
        } catch (IOException e) {
            System.out.println("Failed to read the file:" + e);
        }

        System.out.println(values.size());
        ArrayList<Long> values_array =  new ArrayList<Long>(values);
        Collections.sort(values_array);

        HashSet<Long> ss = new HashSet<Long>();
        HashSet<String> used_numbers = new HashSet<String>();
        for (int i = 0; i < values_array.size(); i++) {
            int ndx1 = Math.abs(Collections.binarySearch(values_array, -10000L - values_array.get(i)));
            int ndx2 = Math.abs(Collections.binarySearch(values_array, 10000L - values_array.get(i)));
//            System.out.println(values_array.get(i) + " -> best chance is between " + ndx1 + " and " + ndx2);
            int min_index = Math.max(Math.min(ndx1, ndx2) - 1, 0);
            int max_index = Math.min(Math.max(ndx1, ndx2) + 1, values_array.size());
            for (int k = min_index; k < max_index; k++) {
                long new_value = values_array.get(i) + values_array.get(k);
                if (Math.abs(new_value) <= 10000 && i != k) {
                    if (!used_numbers.contains(i + ":" + k) && !used_numbers.contains(k + ":" + i)) {
                        System.out.println("at " + i + " and " + k + ":" + values_array.get(i) + "+" + values_array.get(k) + "=" + new_value);
                        used_numbers.add(i + ":" + k);
                        used_numbers.add(k + ":" + i);
                        ss.add(new_value);
                    }
                }
            }
        }

        System.out.println(ss.size());
        System.out.println(used_numbers.size() / 2);

        HashSet<String> pairs = new HashSet<String>();
        for (int i = -10000; i <= 10000; i++) {
            System.out.println(i + " " + pairs.size());
            for (int j = 0; j < values_array.size(); j++ ) {
                if (values.contains(i - values_array.get(j))) {
                    pairs.add(i + ":" + j);
                    break;
                }
            }
        }

        System.out.println(pairs.size());

    }
}
