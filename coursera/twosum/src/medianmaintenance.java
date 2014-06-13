import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.PriorityQueue;

public class medianmaintenance {
    public static void main(String[] args) {

        ArrayList<Long> numbers = new ArrayList<Long>();
        try {
            java.io.File f = new java.io.File("d:\\coursera\\Median.txt");
            java.io.BufferedReader br = new BufferedReader(new FileReader(f));

            while(true) {
                String s = br.readLine();
                if (s == null) {
                    break;
                }
                numbers.add(Long.parseLong(s));
            }
        } catch (FileNotFoundException e) {
            System.err.println(String.format("Failed to read from file %s", e));
        } catch (IOException e) {
            System.err.println(String.format("Failed to read from file %s", e));
        }

        ArrayList<Long> medians = new ArrayList<Long>(numbers.size());

        PriorityQueue<Long> lower = new PriorityQueue<Long>(
            numbers.size() / 2,
            new Comparator<Long>() {
                @Override
                public int compare(Long o1, Long o2) {
                    return o2 - o1 > 0? 1:
                            o2 == o1? 0:
                            -1;
                }
            }
        );
        PriorityQueue<Long> higher = new PriorityQueue<Long>(
                numbers.size() / 2,
                new Comparator<Long>() {
                    @Override
                    public int compare(Long o1, Long o2) {
                        return o1 - o2 > 0? 1:
                                o2 == o1? 0:
                                        -1;
                    }
                }
        );

        for (int i = 0; i < numbers.size(); i++) {
            Long c = numbers.get(i);
            Long lowerpeek = lower.peek();
            if (lowerpeek != null && c > lowerpeek) {
                higher.add(c);
            } else {
                lower.add(c);
            }
            if (Math.abs(lower.size() - higher.size()) > 1) {
                if (lower.size() > higher.size()) {
                    higher.add(lower.poll());
                } else {
                    lower.add(higher.poll());
                }
            }
            int j = i + 1;
            int ndx = ((((j & 1) == 1)? (j+1) : j) >> 1);
            medians.add(ndx > lower.size()? higher.peek(): lower.peek());
//            System.out.println("ndx=" + ndx + " " + lower + ":" + higher);
//            System.out.println(medians.get(medians.size()-1));
        }

        Long medianssum = 0L;
        for (Long median: medians) {
            medianssum += median;
        }

        System.out.println(medianssum % 10000);
    }
}