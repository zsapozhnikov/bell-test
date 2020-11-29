<?php

namespace App\DataTransformer;

use App\Dto\AuthorOutput;
use App\Entity\Author;
use App\Entity\Book;
use PHPUnit\Framework\TestCase;

class AuthorOutputDataTransformerTest extends TestCase
{
    private $authorOutputDataTransformer;

    protected function setUp()
    {
        $this->authorOutputDataTransformer = new AuthorOutputDataTransformer();
    }

    public function testTransform()
    {
        $author = new Author();
        $author->setFirstName('First');
        $author->setLastName('Last');

        $actual = $this->authorOutputDataTransformer->transform($author, AuthorOutput::class);
        $this->assertInstanceOf(AuthorOutput::class, $actual);
        $this->assertEquals('First Last', $actual->name);
    }

    /**
     * @dataProvider supportsTransformationDataProvider
     */
    public function testSupportsTransformation($object, $to, $expected)
    {
        $actual = $this->authorOutputDataTransformer->supportsTransformation($object, $to);
        $this->assertEquals($expected, $actual);
    }


    public function supportsTransformationDataProvider()
    {
        return [
            [
                new Author(),
                AuthorOutput::class,
                true,
            ],
            [
                new Book(),
                AuthorOutput::class,
                false,
            ],
        ];
    }
}
