package com.esoft;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import org.apache.commons.lang.StringUtils;

import com.mysql.jdbc.Connection;
import com.mysql.jdbc.DatabaseMetaData;
import com.mysql.jdbc.PreparedStatement;
import com.mysql.jdbc.Statement;

public class PbtConverter {

	private static final String SQL_INSERT = "INSERT INTO ${table}(${keys}) VALUES(${values})";
	private static final String TABLE_REGEX = "\\$\\{table\\}";
	private static final String KEYS_REGEX = "\\$\\{keys\\}";
	private static final String VALUES_REGEX = "\\$\\{values\\}";

	private static final String CONF_PROPERTIES = "/conf/config.properties";
	private static final String DIR_SQL = "DirSql";
	private static final String DIR_IN = "DirIn";

	public static void main(String[] args) {

		if (args.length != 1) { 
			System.out.println("Argument incorrect usage :  install|uninstall|import|undo_import");
		} else {
			switch (args[0]) {
			case "install":
				System.out.println("Chargement des procedures d'installation");
				try {
					File directory = new File (".");
					Properties prop = load(directory.getAbsolutePath().concat(CONF_PROPERTIES));
					Connection conn = getConnection(prop);
					String dirSql = prop.getProperty(DIR_SQL);
					installSqlFiles(conn,directory.getCanonicalPath(), new File(dirSql), prop);

				} catch (FileNotFoundException e) {
					System.out.println("Erreur lors de la lecture ou d'ecriture de fichier");
					e.printStackTrace();
				} catch (IOException e) {
					System.out.println("Erreur lors de la lecture du fichier de configuration");
					e.printStackTrace();
				} catch (ClassNotFoundException e) {
					System.out.println("Impossible de charger le drivers MySQL");
					e.printStackTrace();
				} catch (SQLException e) {
					System.out.println("Erreur lors de l'insertion de donnees en base");
					e.printStackTrace();
				}
				break;
			case "uninstall":
				System.out.println("Chargement des procedures de desinstallation");
				try {
					File directory = new File (".");
					Properties prop = load(directory.getAbsolutePath().concat(CONF_PROPERTIES));
					Connection conn = getConnection(prop);
					String dirSql = prop.getProperty(DIR_SQL);
					unInstallSqlFiles(conn,directory.getCanonicalPath(), new File(dirSql), prop);
				} catch (FileNotFoundException e) {
					System.out.println("Erreur lors de la lecture ou d'ecriture de fichier");
					e.printStackTrace();
				} catch (IOException e) {
					System.out.println("Erreur lors de la lecture du Fichier de configuration");
					e.printStackTrace();
				} catch (ClassNotFoundException e) {
					System.out.println("Impossible de charger le drivers MySQL");
					e.printStackTrace();
				} catch (SQLException e) {
					System.out.println("Erreur lors de l'insertion de donnees en base");
					e.printStackTrace();
				}
				break;
			case "import":
				System.out.println("Chargement des procedures de desinstallation");
				try {
					File directory = new File (".");
					Properties prop = load(directory.getAbsolutePath().concat(CONF_PROPERTIES));
					Connection conn = getConnection(prop);
					String dirIn = prop.getProperty(DIR_IN);
					String dirSql = prop.getProperty(DIR_SQL);
					doImport(conn,directory.getCanonicalPath(), new File(dirIn),new File(dirSql), prop);

				} catch (FileNotFoundException e) {
					System.out.println("Erreur lors de la lecture ou d'ecriture de fichier");
					e.printStackTrace();
				} catch (IOException e) {
					System.out.println("Erreur lors de la lecture du fichier de configuration");
					e.printStackTrace();
				} catch (ClassNotFoundException e) {
					System.out.println("Impossible de charger le drivers MySQL");
					e.printStackTrace();
				} catch (SQLException e) {
					System.out.println("Erreur lors de l'insertion de donnees en base");
					e.printStackTrace();
				}
				break;
			case "undo_import":
				try { 
					File directory = new File (".");
					Properties prop = load(directory.getAbsolutePath().concat(CONF_PROPERTIES));
					Connection conn = getConnection(prop);
					String dirSql = prop.getProperty(DIR_SQL);
					undoImportSqlFiles(conn,directory.getCanonicalPath(), new File(dirSql), prop);
				} catch (FileNotFoundException e) {
					System.out.println("Erreur lors de la lecture ou d'ecriture de fichier");
					e.printStackTrace();
				} catch (IOException e) {
					System.out.println("Erreur lors de la lecture du Fichier de configuration");
					e.printStackTrace();
				} catch (ClassNotFoundException e) {
					System.out.println("Impossible de charger le drivers MySQL");
					e.printStackTrace();
				} catch (SQLException e) {
					System.out.println("Erreur lors de l'insertion de donnees en base");
					e.printStackTrace();
				}
				break;
			default:
				System.out.println("Argument incorrect usage :  install|uninstall|import|undo_import");
				break;
			}
			System.out.println("Traitement termine");
		}
	}

	private static Properties load(String filename) throws IOException, FileNotFoundException{
		System.out.println("Chargement des configurations");
		Properties properties = new Properties();
		FileInputStream input = new FileInputStream(filename);

		try{
			properties.load(input);
			return properties;
		}
		finally{
			input.close();
			System.out.println("Chargement des configurations termine");
		}	}

	private static void doImport(Connection conn,String mainDir, File repertoire, File RepSql,  Properties prop) throws ClassNotFoundException, IOException, SQLException{
		System.out.println("Traitement d'import des fichiers en base"); 
		String [] listefichiers; 
		int i; 
		String dirOut = prop.getProperty("DirOut");
		File dirOutFile = new File(mainDir + "\\" + dirOut);

		listefichiers=repertoire.list();
		Arrays.sort(listefichiers);
		for(i=0;i<listefichiers.length;i++){ 
			if(listefichiers[i].endsWith(".csv")==true){ 
				System.out.println("traitement du fichier "  + listefichiers[i]); 
				convertirFichier(conn,repertoire.getAbsolutePath() + "\\" +  listefichiers[i], 
						dirOutFile.getAbsolutePath() + "\\" + "gen_" + listefichiers[i], 
						dirOutFile.getAbsolutePath() + "\\" + "det_" + listefichiers[i],
						prop, mainDir, RepSql);
			} 
		}
		if (!prop.getProperty("CallImportProcInLoop").equalsIgnoreCase("true")) { 
			System.out.println("Traitement d'import des fichiers en base termine"); 
			doImportSqlFiles(conn,mainDir,RepSql,prop);
			System.out.println("Traitement d'import termine");
		}
	}

	private static void installSqlFiles(Connection conn,String mainDir, File repertoire, Properties prop) throws ClassNotFoundException, IOException, SQLException{ 
		System.out.println("Installation des tables et procedures"); 
		doSqlFiles(conn,mainDir,repertoire,prop,"_install_");
		System.out.println("Installation des tables et procedures terminee"); 
	}

	private static void unInstallSqlFiles(Connection conn,String mainDir, File repertoire, Properties prop) throws ClassNotFoundException, IOException, SQLException{ 
		System.out.println("desinstallation des tables et procedures"); 
		doSqlFiles(conn,mainDir,repertoire,prop,"_unInstall_");
		System.out.println("desinstallation des tables et procedures terminee"); 
	}

	private static void doImportSqlFiles(Connection conn,String mainDir, File repertoire, Properties prop) throws ClassNotFoundException, IOException, SQLException{ 
		System.out.println("Appel des procedures d'import"); 
		doSqlParamFiles(conn,mainDir,repertoire,prop,"_setParam_");
		doSqlFiles(conn,mainDir,repertoire,prop,"_doImport_");
		System.out.println("Appel des procedures d'import termine"); 
	}

	private static void undoImportSqlFiles(Connection conn,String mainDir, File repertoire, Properties prop) throws ClassNotFoundException, IOException, SQLException{ 
		System.out.println("Appel des procedures d'annulation d'import"); 
		doSqlFiles(conn,mainDir,repertoire,prop,"_undoImport_");
		System.out.println("Appel des procedures d'annulation d'import termine"); 
	}

	private static void doSqlFiles(Connection conn,String mainDir, File repertoire, Properties prop, String partFileName) throws ClassNotFoundException, IOException, SQLException{ 
		String [] listefichiers; 
		int i; 
		String dirSql = prop.getProperty("DirSql");
		File dirSqlFile = new File(mainDir + "\\" + dirSql);

		listefichiers=repertoire.list(); 
		Arrays.sort(listefichiers);
		for(i=0;i<listefichiers.length;i++){ 
			if(listefichiers[i].endsWith(".sql")==true&&(listefichiers[i].contains(partFileName))) { 
				System.out.println("traitement du fichier "  + listefichiers[i]);
				execSqlFile((Statement) conn.createStatement(),dirSqlFile.getAbsolutePath() + "\\" +listefichiers[i], new HashMap());
				conn.commit();
			} 
		}
	}

	private static void doSqlParamFiles(Connection conn,String mainDir, File repertoire, Properties prop, String partFileName) throws ClassNotFoundException, IOException, SQLException{ 
		String [] listefichiers; 
		int i; 
		String dirSql = prop.getProperty("DirSql");
		File dirSqlFile = new File(mainDir + "\\" + dirSql);
		Map argMap = new HashMap();

		for (Iterator iterator = prop.keySet().iterator(); iterator.hasNext();) {
			String propkey = (String) iterator.next();
			if (propkey.startsWith("MySqlVar")) {
				String propval = prop.getProperty(propkey);
				String key = propval.substring(0, propval.indexOf(","));
				String val = propval.substring(propval.indexOf(",") + 1);
				argMap.put(key, val);
			}
		}		

		listefichiers=repertoire.list(); 
		Arrays.sort(listefichiers);
		for(i=0;i<listefichiers.length;i++){ 
			if(listefichiers[i].endsWith(".sql")==true&&(listefichiers[i].contains(partFileName))) { 
				System.out.println("traitement du fichier "  + listefichiers[i]);
				execSqlFile((Statement) conn.createStatement(),dirSqlFile.getAbsolutePath() + "\\" +listefichiers[i], argMap);
				conn.commit();
			} 
		}
	}

	private static void convertirFichier(Connection conn, String fichierIn, String fichierOutGen, String fichierOutDet, Properties prop, String mainDir, File RepSql) throws IOException, ClassNotFoundException, SQLException{
		int i = 0;

		System.out.println("alimentation des tables tmp_cmd_gen et tmp_cmd_det"); 
		//lecture du fichier texte	
		String sqlBase = prop.getProperty("MySqlBASE");
		int batchSize = ( prop.getProperty("MySqlBatchSize") == null ? 100 : Integer.valueOf(prop.getProperty("MySqlBatchSize"))) ;
		String[] headerGen = new String[101]; 
		String[] headerTypeGen = new String[101]; 
		int[] headerSizeGen = new int[101]; 
		String[] headerDet = new String[63]; 
		String[] headerTypeDet = new String[63]; 
		int[] headerSizeDet = new int[63];
		HashSet<String> rtrimColSet = new HashSet<String>();
		HashSet<String> replaceColSet = new HashSet<String>();
		HashSet<String> replaceAllSet = new HashSet<String>();
		String separator = ( prop.getProperty("Separator") == null ? ";" : prop.getProperty("Separator")) ;

		FileWriter fwGen = new FileWriter (fichierOutGen);
		BufferedWriter bwGen = new BufferedWriter (fwGen);
		PrintWriter fichierSortieGen = new PrintWriter (bwGen); 

		FileWriter fwDet = new FileWriter (fichierOutDet);
		BufferedWriter bwDet = new BufferedWriter (fwDet);
		PrintWriter fichierSortieDet = new PrintWriter (bwDet);

		InputStream ips=new FileInputStream(fichierIn); 
		InputStreamReader ipsr=new InputStreamReader(ips);
		BufferedReader br=new BufferedReader(ipsr);

		initEntetes(conn, "tmp_cmd_gen",headerGen, headerTypeGen,headerSizeGen,sqlBase  );
		initEntetes(conn, "tmp_cmd_det",headerDet, headerTypeDet,headerSizeDet,sqlBase  );
		System.out.println("Headers initialized");

		PreparedStatement psGen = initStatetement(conn,"tmp_cmd_gen",headerGen);
		PreparedStatement psDet = initStatetement(conn,"tmp_cmd_det",headerDet);
		System.out.println("Statements initialized");

		conn.createStatement().execute("CALL pr_create_main_tables()");
		conn.createStatement().execute("CALL pr_create_tmp_tables()");
		System.out.println("tmp tables truncated");

		for (Iterator iterator = prop.keySet().iterator(); iterator.hasNext();) {
			String key = (String) iterator.next();
			if (key.startsWith("ReplaceCol")) {
				replaceColSet.add(prop.getProperty(key));
			}
			if (key.startsWith("ReplaceAll")) {
				replaceAllSet.add(prop.getProperty(key));
			}
			if (key.startsWith("RtrimCol")) {
				rtrimColSet.add(prop.getProperty(key));
			}
		}

		int countGen = 0;
		int countDet = 0;

		String ligne;
		while ((ligne=br.readLine())!=null){
			i++; 
			if (i> 1 ) { 
				ligne = convertirLigne(ligne, replaceAllSet);
				String values[] = ligne.split(separator);

				if (ligne.startsWith("L")) { 
					if (values.length == headerGen.length) {  
						convertirValeurs("tmp_cmd_gen", psGen,values,headerGen,headerTypeGen,headerSizeGen,replaceColSet,rtrimColSet);
						if (++countGen % batchSize == 0) {
							System.out.println("Cumul Insertion de ".concat(Integer.toString(countGen)).concat(" lignes dans tmp_cmd_gen")); 
							psGen.executeBatch();
						} 
					}
					fichierSortieGen.println (ligne);

				} else { 
					if (values.length == headerDet.length) {  
						convertirValeurs("tmp_cmd_det", psDet,values,headerDet,headerTypeDet,headerSizeDet, replaceColSet, rtrimColSet);
						if (++countDet % batchSize == 0) {
							System.out.println("Cumul Insertion de ".concat(Integer.toString(countDet)).concat(" lignes dans tmp_cmd_det")); 
							psDet.executeBatch();
						} 
					}
					fichierSortieDet.println (ligne); 
				}
			}

		}
		psGen.executeBatch();
		psDet.executeBatch();
		conn.commit();
		br.close(); 
		fichierSortieGen.close();
		fichierSortieDet.close();
		System.out.println("Total : Insertion de ".concat(Integer.toString(countGen)).concat(" lignes dans tmp_cmd_gen")); 
		System.out.println("Total : Insertion de ".concat(Integer.toString(countDet)).concat(" lignes dans tmp_cmd_det"));
		
		if (prop.getProperty("CallImportProcInLoop").equalsIgnoreCase("true")) { 
			System.out.println("Traitement d'import du fichier".concat(fichierIn).concat(" en base termine")); 
			doImportSqlFiles(conn,mainDir,RepSql,prop);
			System.out.println("Traitement du dichier ".concat(fichierIn).concat(" termine"));
		}

	}

	private static Connection getConnection ( Properties prop) throws ClassNotFoundException, SQLException {
		String url = "jdbc:mysql://" + prop.getProperty("MySqlHOST") + "/" + prop.getProperty("MySqlBASE");
		String user = prop.getProperty("MySqlUSER");
		String pswd = prop.getProperty("MySqlPWD");
		Class.forName("com.mysql.jdbc.Driver");
		Connection conn = null;
		System.out.println("Connecting to database...");
		conn = (Connection) DriverManager.getConnection(url,user,pswd);	
		conn.setAutoCommit(false);
		System.out.println("Connected to database ".concat(url));
		return conn;

	}

	private static String convertirLigne(String ligne, Set replaceAllSet ) {
		for (Iterator iterator = replaceAllSet.iterator(); iterator.hasNext();) {
			String val = (String) iterator.next();
			if ( val.indexOf(",") > 0) { 
				String sch = val.substring(0, val.indexOf(","));
				String rpl = val.substring(val.indexOf(",") + 1);
				ligne = ligne.replaceAll(sch, rpl);
			}
		}
		return ligne;
	}

	private static void convertirValeurs(String tableName,PreparedStatement ps, String values[], String header[], String headerType[], int headerSize[], Set replaceInCol, Set rtrimColSet ) throws NumberFormatException, SQLException {
		if (values.length == header.length) {  
			for (int j = 0; j < values.length; j++) {
				switch (headerType[j]) { 
				case "INT": 
					ps.setInt(j+1, Integer.valueOf(values[j].replaceAll(" ","").replaceAll("0,00","0")));
					break;
				case "BIGINT":
					ps.setLong(j+1, Long.valueOf(values[j].replaceAll(" ","").replaceAll("0,00","0")));
					break;
				default:
					values[j] = values[j].trim();
					if (values[j].length() > headerSize[j] ) { 
						values[j] = values[j].substring(1, headerSize[j]);
					}

					for (Iterator iterator = replaceInCol.iterator(); iterator.hasNext();) {
						String val = (String) iterator.next();
						if ( val.indexOf(",") > 0) { 
							if (values[j].startsWith(val.substring(0, val.indexOf(",")))) { 
								values[j] = val.substring(val.indexOf(",") + 1);
							}
						}
					}

					for (Iterator iterator = rtrimColSet.iterator(); iterator.hasNext();) {
						String val = (String) iterator.next();
						if ( val.indexOf(",") > 0) {
							String tblName = val.substring(0, val.indexOf(","));
							if (tblName.equals(tableName)) { 
								String val2 = val.substring(val.indexOf(",") + 1);
								if ( val2.indexOf(",") > 0) {
									String ColName = "`".concat(val2.substring(0, val2.indexOf(","))).concat("`"); 
									if (ColName.equals(header[j])) {
										int rTrimLength = Integer.valueOf(val2.substring(val2.indexOf(",") +  1));
										values[j] = values[j].substring(rTrimLength,  values[j].length());
									}
								}
							}
						}
					}

					ps.setString(j+1, values[j]);
					break;
				}
			}
			ps.addBatch();
		}
	}

	private static PreparedStatement initStatetement(Connection conn, String tableName, String header[] ) throws SQLException {
		String questionmarksGen = StringUtils.repeat("?,", header.length);
		questionmarksGen = (String) questionmarksGen.subSequence(0, questionmarksGen.length() - 1);
		String query = SQL_INSERT.replaceFirst(TABLE_REGEX, tableName);
		query = query.replaceFirst(KEYS_REGEX, StringUtils.join(header, ","));
		query = query.replaceFirst(VALUES_REGEX, questionmarksGen);
		return (PreparedStatement) conn.prepareStatement(query);
	}

	private static void initEntetes(Connection conn, String tableName, String header[], String headerType[], int headerSize[], String sqlBase ) throws SQLException {
		DatabaseMetaData metadataGen = (DatabaseMetaData) conn.getMetaData();
		ResultSet columnsGen = metadataGen.getColumns(sqlBase, null, tableName, null);
		int k = 0;
		while (columnsGen.next())
		{
			if ( k <= header.length)  { 
				header[k] = "`".concat(columnsGen.getString("COLUMN_NAME").concat("`")); 
				headerType[k] = columnsGen.getString("TYPE_NAME"); 
				headerSize[k] = columnsGen.getInt("COLUMN_SIZE");
			}
			k++;
		}
	}

	private static void execSqlFile(Statement st, String sqlFileName,Map argMap) throws IOException, SQLException {
		InputStream ips=new FileInputStream(sqlFileName); 
		InputStreamReader ipsr=new InputStreamReader(ips);
		BufferedReader br=new BufferedReader(ipsr);
		String strglob, str;
		StringBuffer sb = new StringBuffer();
		while ((strglob = br.readLine()) != null) {
			if (!argMap.isEmpty()) { 
				for (Iterator iterator = argMap.keySet().iterator(); iterator.hasNext();) {
					String key = (String) iterator.next();
					String val = (String) argMap.get(key); 
					String strglob2 = strglob.replaceAll("%VARNAME%", key);
					strglob2 = strglob2.replaceAll("%VARVALUE%", val);

					if (strglob2.contains("$$")) { 
						str = strglob2.substring(0, strglob2.indexOf("$$"));
						sb.append(str + "\n ");
						st.executeUpdate(sb.toString());
						sb = new StringBuffer();
					} else { 
						if (strglob.trim().length() > 0) { 
							sb.append(strglob2 + "\n ");
						}
					}

				}
			} else {
				if (strglob.contains("$$")) { 
					str = strglob.substring(0, strglob.indexOf("$$"));
					sb.append(str + "\n ");
					st.executeUpdate(sb.toString());
					sb = new StringBuffer();
				} else { 
					if (strglob.trim().length() > 0) { 
						sb.append(strglob + "\n ");
					}
				}
			}
		}
		if (sb.length() > 0 ) { 
			st.executeUpdate(sb.toString());
		}
		br.close();
	}

}
