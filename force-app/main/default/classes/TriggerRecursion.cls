public class TriggerRecursion {
    private static Map<String, Boolean> flags = new Map<String, Boolean>();

    public static Boolean isFirstRun(String key) {
        if (!flags.containsKey(key)) {
            flags.put(key, true);
            return true;
        }
        return false;
    }

    public static void reset() {
        flags.clear();
    }
}
