import java.util.*;

class Main {
  private static int n;
  private static int[][] board;
  private static int[] dx = { -2, -2, -1, -1, 1, 1, 2, 2 };
  private static int[] dy = { 1, -1, 2, -2, 2, -2, 1, -1 };

  public static void main(String[] args) {
    Scanner sc = new Scanner(System.in);
    System.out.print("Enter the size of the board ");
    n = sc.nextInt();

    board = new int[n + 1][n + 1];

    int row = n;
    int col = 1;

    if (findTour(row, col, 1)) {

      printBoard();
    } else {

      System.out.println("No solution found.");
    }
  }

  private static boolean findTour(int row, int col, int count) {

    board[row][col] = count;

    if (count == n * n) {
      return true;
    }

    ArrayList<int[]> moves = generateMoves(row, col);

    Collections.sort(moves, new Comparator<int[]>() {
      public int compare(int[] a, int[] b) {
        ArrayList<int[]> aMoves = generateMoves(a[0], a[1]);
        ArrayList<int[]> bMoves = generateMoves(b[0], b[1]);
        return Integer.compare(aMoves.size(), bMoves.size());
      }
    });

    for (int[] move : moves) {
      int nextRow = move[0];
      int nextCol = move[1];
      if (board[nextRow][nextCol] == 0 && findTour(nextRow, nextCol, count + 1)) {
        return true;
      }
    }

    board[row][col] = 0;
    return false;
  }

  private static ArrayList<int[]> generateMoves(int row, int col) {
    ArrayList<int[]> moves = new ArrayList<>();
    for (int i = 0; i < dx.length; i++) {
      int nextRow = row + dx[i];
      int nextCol = col + dy[i];
      if (nextRow >= 1 && nextRow <= n && nextCol >= 1 && nextCol <= n) {
        moves.add(new int[] { nextRow, nextCol });
      }
    }
    return moves;
  }

  private static void printBoard() {
    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= n; j++) {
        System.out.print(board[i][j] + "\t");
      }
      System.out.println();
    }
  }
}