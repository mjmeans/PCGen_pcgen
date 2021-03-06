/*
 * Copyright 2013 (C) James Dempsey <jdempsey@users.sourceforge.net>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */
package pcgen.inttest;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.util.Locale;

import pcgen.LocaleDependentTestCase;
import pcgen.cdom.base.Constants;
import pcgen.system.Main;
import pcgen.util.TestHelper;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.xmlunit.builder.DiffBuilder;
import org.xmlunit.builder.Input;
import org.xmlunit.diff.Diff;

/**
 * PcgenFtlTestCase is a base class for tests which use the FreeMarker
 * base template to produce an XML output for a character and then compare that
 * output with the expected result.
 */
public abstract class PcgenFtlTestCase
{
	private static final String TEST_CONFIG_FILE = "config.ini.junit";

	@Before
	public void setUp() throws Exception
	{
		LocaleDependentTestCase.before(Locale.US);
	}

	@After
	public void tearDown() throws Exception
	{
		LocaleDependentTestCase.after();
	}

	/**
	 * Run the test.
	 *
	 * @param character The PC
	 * @param mode The game mode
	 * @throws IOException Signals that an I/O exception has occurred.
	 */
	public static void runTest(String character, String mode) throws IOException
	{
		System.out.println("RUNTEST with the character: " + character
				+ " and the game mode: " + mode);
		// Delete the old generated output for this test
		File outputFolder = new File("code/testsuite/output");
		outputFolder.mkdirs();
		String outputFileName = character + ".xml";
		File outputFileFile = new File(outputFolder, outputFileName);
		outputFileFile.delete();

		String pccLoc = TestHelper.findDataFolder();

		// The String holder for the XML of the expected result
		String expected;
		// The String holder for the XML of the actual result
		String actual;
		/*
		 * Override the pcc location, game mode and several other properties in
		 * the options.ini file
		 */
		try
		{
			String configFolder = "testsuite";
			TestHelper.createDummySettingsFile(TEST_CONFIG_FILE, configFolder,
					pccLoc);

			// Fire off PCGen, which will produce an XML file
			String characterFile = "code/testsuite/PCGfiles/" + character
					+ Constants.EXTENSION_CHARACTER_FILE;

			String outputFile = outputFileFile.getCanonicalPath();
			Assert.assertTrue("Export of " + character + " failed.",
					Main.loadCharacterAndExport(characterFile, "code/testsuite/base-xml.ftl",
							outputFile, TEST_CONFIG_FILE));

			// Read in the actual XML produced by PCGen
			actual = readFile(new File(outputFile));
			// Read in the expected XML
			expected = readFile(
					new File("code/testsuite/csheets/" + character + ".xml"));
		}
		finally
		{
			new File(TEST_CONFIG_FILE).delete();
		}

		Diff myDiff = DiffBuilder.compare(Input.fromString(expected))
		                         .withTest(Input.fromString(actual)).build();

		Assert.assertFalse(myDiff.toString(), myDiff.hasDifferences());
	}

	/**
	 * Read the XML file and return it as a String.
	 * @param outputFile
	 * @return String
	 *
	 * @throws UnsupportedEncodingException
	 * @throws FileNotFoundException
	 * @throws IOException
	 */
	private static String readFile(File outputFile)
			throws UnsupportedEncodingException, FileNotFoundException, IOException
	{
		BufferedReader br =
				new BufferedReader(new InputStreamReader(new FileInputStream(
						outputFile), StandardCharsets.UTF_8));
		StringBuilder output = new StringBuilder();
		try
		{
			String line = br.readLine();
			while (line != null)
			{
				output.append(line).append('\n');
				line = br.readLine();
			}
		}
		catch (IOException e)
		{
			br.close();
			Assert.fail();
		}
		return output.toString();
	}
}
